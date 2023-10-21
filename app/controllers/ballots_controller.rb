class BallotsController < ApplicationController
  before_action :set_ballot, only: %i[ update destroy deliver ]
  before_action :set_voting, only: %i[ update destroy ]

  # POST /ballots or /ballots.json
  def create
    authorize Ballot
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

  def update
    if authorized_voter?
      respond_to do |format|
        if @ballot.update(choice: params[:choice])
          format.html { redirect_back_or_to @voting, notice: "Your vote was accepted." }
          format.json { render :show, status: :ok, location: @ballot }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @ballot.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /ballots/1 or /ballots/1.json
  def destroy
    authorize @ballot
    @ballot.destroy!

    respond_to do |format|
      format.html { redirect_to @voting, notice: "Ballot was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def deliver
    if (current_user == @ballot.voting.user) || authorized_voter?
      BallotMailer.with(ballot: @ballot, exp: params[:exp]).ballot.deliver_later
      @ballot.update(is_delivered: true)
      @ballot.save
    end

    respond_to do |format|
      format.html { redirect_back_or_to @ballot.voting, notice: "Ballot was successfully delivered." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ballot
      @ballot = Ballot.find(params[:id])
    end

    def set_voting
      @voting = @ballot.voting
    end

    def authorized_voter?
      (@ballot.voter == params[:v]) && (@ballot.authenticate(params[:p]))
    end

    # Only allow a list of trusted parameters through.
    def ballot_params
      params.require(:ballot).permit(:voting_id, :voter, :password_digest, :choice, :exp)
    end
end
