class BallotsController < ApplicationController
  before_action :set_ballot, only: %i[ show edit update destroy deliver ]

  # GET /ballots or /ballots.json
  def index
    @ballots = Ballot.all
  end

  # GET /ballots/1 or /ballots/1.json
  def show
  end

  # GET /ballots/new
  def new
    @ballot = Ballot.new
  end

  # GET /ballots/1/edit
  def edit
  end

  # POST /ballots or /ballots.json
  def create
    @ballot = Ballot.new(ballot_params)

    respond_to do |format|
      if @ballot.save
        format.html { redirect_to ballot_url(@ballot), notice: "Ballot was successfully created." }
        format.json { render :show, status: :created, location: @ballot }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ballot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ballots/1 or /ballots/1.json
  def update
    respond_to do |format|
      if @ballot.update(ballot_params)
        format.html { redirect_to ballot_url(@ballot), notice: "Ballot was successfully updated." }
        format.json { render :show, status: :ok, location: @ballot }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ballot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ballots/1 or /ballots/1.json
  def destroy
    @voting = @ballot.voting
    @ballot.destroy!

    respond_to do |format|
      format.html { redirect_to @voting, notice: "Ballot was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def deliver
    BallotMailer.with(ballot: @ballot, exp: params[:exp]).ballot.deliver_later
    @ballot.update(is_delivered: true)
    @ballot.save
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ballot
      @ballot = Ballot.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def ballot_params
      params.require(:ballot).permit(:voting_id, :voter, :password_digest, :choice, :exp)
    end
end
