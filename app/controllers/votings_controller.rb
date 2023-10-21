class VotingsController < ApplicationController
  before_action :set_voting, only: %i[ show edit update destroy issue deliver_all ]

  # (method: GET) Show voting page via votings/{uuid}
  def show
    @ballot = @voting.get_ballot(voter: params[:v], password: params[:p])

    unless (current_user == @voting.user) || @ballot
      raise ActionController::RoutingError.new('Not Found')
    end

    @voter = params[:v]
    @password = params[:p]
    @result = @voting.count_votes
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
        format.html { redirect_to voting_url(@voting), notice: "Voting was successfully created." }
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
  end

  # (method: PUT/PATCH) Edit voting with params
  def update
    authorize @voting
    respond_to do |format|
      if @voting.update(voting_params)
        format.html { redirect_to voting_url(@voting), notice: "Voting was successfully updated." }
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
      format.html { redirect_to mypage_path, notice: "Voting was successfully destroyed." }
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
      format.html { redirect_to @voting, notice: "Voter was successfully added."}
      format.json { head :no_content }
    end
  end

  def deliver_all
    authorize @voting

    @voting.ballots.where(is_delivered: nil).each do |ballot|
      BallotMailer.with(ballot: ballot, exp: params[:exp]).ballot.deliver_later
      ballot.update(is_delivered: true)
      ballot.save
    end

    respond_to do |format|
      format.html { redirect_to @voting, notice: "Ballots are successfully delivered."}
      format.json { head :no_content }
    end
  end

  private
    def set_voting
      @voting = Voting.find(params[:id])
    end

    def voting_params
      params.require(:voting).permit(:title, :description, :choices, :deadline, :mode, :config).merge(user_id: current_user.id)
    end
end
