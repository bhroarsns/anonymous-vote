class BallotsController < ApplicationController
  before_action :set_ballot_and_voting, only: %i[ update destroy deliver ]

  # owner only
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

  # voter only
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

  # owner only
  def destroy
    authorize @ballot
    @ballot.destroy!

    respond_to do |format|
      format.html { redirect_back_or_to voters_voting_path(@voting), notice: "Ballot was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # voter or owner
  def deliver
    if (current_user == @ballot.voting.user) || authorized_voter?
      BallotMailer.with(ballot: @ballot, exp: params[:exp]).ballot.deliver_later
      @ballot.update(is_delivered: true)
      @ballot.save
    end

    respond_to do |format|
      format.html { redirect_back_or_to @voting, notice: "Ballot was successfully delivered." }
      format.json { head :no_content }
    end
  end

  private
    def set_ballot_and_voting
      @ballot = Ballot.find(params[:id])
      @voting = @ballot.voting
    end

    def authorized_voter?
      (@ballot.voter == params[:v]) && (@ballot.authenticate(params[:p]))
    end

    def ballot_params
      params.require(:ballot).permit(:voting_id, :voter, :password_digest, :choice, :exp)
    end
end
