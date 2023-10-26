class VotingsController < ApplicationController
  before_action :set_voting_voter_password, only: %i[ show edit update destroy issue deliver_all voters ]

  # (method: GET) Show voting page via votings/{uuid}
  def show
    @ballot = @voting.get_ballot(voter: @voter, password: @password)
    @owner = @voting.user

    unless (current_user == @owner) || @ballot
      raise ActionController::RoutingError.new('Not Found')
    end

    @title = @voting.title
    @owner_name = @owner.name
    @start = @voting.start
    @deadline = @voting.deadline
    @description = @voting.description
    @choices = @voting.get_choices
    @num_voters = @voting.ballots.count
    @num_not_delivered = @voting.count_not_delivered
    @num_delete_requested = @voting.count_delete_request
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
    @delivered_exist = @voting.delivered_exist
  end

  # (method: PUT/PATCH) Edit voting with params
  def update
    authorize @voting
    respond_to do |format|
      if @voting.update(voting_params)
        format.html { redirect_to voting_url(@voting, v:@voter, p:@password), notice: "変更を保存しました." }
        format.json { render :show, status: :ok, location: @voting }
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

  def issue
    authorize @voting
    if params[:file]
      @voting.issue_ballots(params[:file])
    else
      @voting.issue_single_ballot(params[:email])
    end

    respond_to do |format|
      format.html { redirect_to voters_voting_path(@voting, v:@voter, p:@password), notice: "参加者が追加されました."}
      format.json { head :no_content }
    end
  end

  def deliver_all
    authorize @voting

    @voting.ballots.where(delivered: nil).each do |ballot|
      BallotMailer.with(ballot: ballot, exp: @voting.exp_at_delivery, voting: @voting).ballot_from_owner.deliver_later
      ballot.update(delivered: true)
      ballot.save
    end

    respond_to do |format|
      format.html { redirect_to voters_voting_path(@voting, v:@voter, p:@password), notice: "送信されました."}
      format.json { head :no_content }
    end
  end

  def voters
    authorize @voting
    @ballots = @voting.ballots.order(:delivered, delete_requested: :desc, voter: :asc)
    @num_voters = @ballots.count
    @num_not_delivered = @voting.count_not_delivered
    @num_delete_requested = @voting.count_delete_request

    respond_to do |format|
      format.html
      format.csv do |csv|
        self.send_voters_csv
      end
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

    def voting_params
      params[:voting][:choices] = params[:voting][:choices].split("\n").uniq.join("\n")
      params.require(:voting).permit(:title, :description, :choices, :start, :deadline, :mode, :config).merge(user_id: current_user.id)
    end
end
