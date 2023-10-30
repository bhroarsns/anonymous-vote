class VotingsController < ApplicationController
  before_action :sign_in_required, only: [:new]
  # All request except :new have to have this callback to retain :voter and :password when owner opens their own vote link and move to other page
  before_action :set_voting_voter_password, only: %i[ show edit update destroy issue_single issue deliver_all voters ]
  before_action :deny_when_closed, only: [:issue_single, :issue, :deliver_all]

  # (method: GET) Show voting page via votings/{uuid}
  def show
    @ballot = @voting.get_ballot(voter: @voter, password: @password)
    @owner = @voting.user

    @title = @voting.title
    @owner_name = @owner.name
    @start = @voting.start
    @deadline = @voting.deadline
    @description = @voting.description
    @choices = @voting.choices_array
    @num_voters = @voting.ballots.count
    @num_not_delivered = @voting.count_not_delivered
    @num_delete_requests = @voting.count_delete_requests
    @status = @voting.status
    @count = @voting.count_votes
    @not_for_me = params[:not_for_me]

    if @ballot
      @choice = @ballot.choice
      @expired = @ballot.expired?
      @exp = @ballot.exp
    end
  end

  # (method: GET) Show voting creation page via votings/new
  def new
    authorize Voting
    @voting = Voting.new
  end

  # (method: POST) Create voting with params
  def create
    authorize Voting
    @voting = Voting.new(voting_params)

    respond_to do |format|
      if @voting.save
        format.html { redirect_to voting_url(@voting), notice: "投票を作成しました." }
        format.json { render :show, status: :created, location: @voting }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @voting.errors, status: :unprocessable_entity }
      end
    end
  end

  # (method: GET) Show voting edit page via votings/{uuid}/edit
  def edit
    authorize @voting
    @locks = @voting.attr_locks
  end

  # (method: PUT/PATCH) Edit voting with params
  def update
    authorize @voting
    respond_to do |format|
      if @voting.update(voting_params)
        @changes_to_report = @voting.saved_changes_to_report
        format.html { redirect_to voting_url(@voting, v:@voter, p:@password), notice: "変更を保存しました." }
        format.json { render :show, status: :ok, location: @voting }

        unless @changes_to_report.nil? || @changes_to_report.empty?
          @voting.ballots.where(delivered: true, delete_requested: false).each do |ballot|
            sleep(ENV['SLEEP_EMAIL'].to_i)
            BallotMailer.with(address: ballot.voter, voting: @voting, changes: @changes_to_report).voting_changed.deliver_later
          end
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @voting.errors, status: :unprocessable_entity }
      end
    end
  end

  # (method: DELETE) Delete voting
  def destroy
    authorize @voting
    @voting.destroy!

    respond_to do |format|
      # redirect to mypage because there is no routing GET "/votings"
      format.html { redirect_to mypage_path, notice: "投票は削除されました." }
      format.json { head :no_content }
    end
  end

  # (method: GET) manage voters of voting
  def voters
    authorize @voting
    @ballots = @voting.ballots.order(:delivered, delete_requested: :desc, voter: :asc)
    @num_voters = @ballots.count
    @num_not_delivered = @voting.count_not_delivered
    @num_delete_requests = @voting.count_delete_requests
    @status = @voting.status

    respond_to do |format|
      format.html
      format.csv do |csv|
        self.send_voters_csv
      end
    end
  end

  # (method: post) issue single ballot from voters page
  def issue_single
    authorize @voting

    result = @voting.issue_new_ballot(params[:email])
    if result.errors.any?
      respond_to do |format|
        format.html { redirect_to voters_voting_path(@voting, v:@voter, p:@password), alert: result.errors.full_messages.join(' ') }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to voters_voting_path(@voting, v:@voter, p:@password), notice: "参加者が追加されました." }
        format.json { head :no_content }
      end
    end
  end

  # (method: post) issue ballots from voters page
  def issue
    authorize @voting
    
    if params[:file]
      result = @voting.issue_ballots(params[:file])

      notice_message = result[:succeeded].any? ? "参加者が#{result[:succeeded].count}人追加されました." : nil

      num_invalid = 0
      voters_taken = []
      result[:failed].each do |failure|
        if failure.errors.of_kind? :voter, :invalid
          num_invalid += 1
        end
        if failure.errors.of_kind? :voter, :taken
          voters_taken << failure[:voter]
        end
      end
      invalid_message = num_invalid > 0 ? "メールアドレスの形式が不正なため#{num_invalid}件をスキップしました." : nil
      taken_message = voters_taken.any? ? "#{voters_taken.join(', ')}はすでに登録されています." : nil
      alert_message = (invalid_message || taken_message) ? [invalid_message, taken_message].compact.join(' ') : nil

      respond_to do |format|
        format.html { redirect_to voters_voting_path(@voting, v:@voter, p:@password), notice: notice_message, alert: alert_message }
        format.json { head :no_content }
      end
    end
  end

  # (method: post) deliver all ballots from voters page
  def deliver_all
    authorize @voting

    exp = @voting.exp_at_delivery
    addresses_and_passwords = []
    @voting.ballots.where(delivered: false).each do |ballot|
      addresses_and_passwords << ballot.renew_password(exp)
    end

    respond_to do |format|
      format.html { redirect_to voters_voting_path(@voting, v:@voter, p:@password), notice: "送信キューに追加しました."}
      format.json { head :no_content }
    end

    addresses_and_passwords.each do |a_p|
      sleep(ENV['SLEEP_EMAIL'].to_i)
      BallotMailer.with(
        address: a_p[:address],
        password: a_p[:password],
        voting: @voting,
        exp: exp,
      ).ballot_from_owner.deliver_later
    end
  end

  private
    def set_voting_voter_password
      @voting = Voting.find(params[:id])
      @voter = params[:v]
      @password = params[:p]
    end

    def send_voters_csv
      csv_data = CSV.generate do |csv|
        @voting.ballots.each do |ballot|
          csv << [ballot.voter]
        end
      end
      send_data(csv_data, filename: "voters.csv")
    end

    def deny_when_closed
      if @voting.status == "closed"
        respond_to do |format|
          format.html { redirect_to voters_voting_path(@voting, v:@voter, p:@password), notice: "投票が終了しているので追加できません."}
          format.json { head :no_content }
        end
      end
    end

    # remove choice duplication
    def voting_params
      if params[:voting][:choices]
        params[:voting][:choices] = params[:voting][:choices].split("\n").uniq.join("\n")
      end
      params.require(:voting).permit(:title, :description, :choices, :start, :deadline, :mode, :config).merge(user_id: current_user.id)
    end
end
