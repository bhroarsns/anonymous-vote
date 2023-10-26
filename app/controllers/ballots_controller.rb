class BallotsController < ApplicationController
  before_action :set_ballot_and_voting, only: %i[ update destroy deliver redeliver deliver_from_owner ]

  # owner only
  def create
    authorize Ballot
    @ballot = Ballot.new(ballot_params)

    respond_to do |format|
      if @ballot.save
        format.html { redirect_to ballot_url(@ballot), notice: "参加者が追加されました." }
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
        if params[:delete_requested]
          if @ballot.update(delete_requested: true)
            format.html { redirect_back_or_to @voting, notice: "取り消し申請を受け付けました." }
            format.json { render :show, status: :ok, location: @ballot }
          else
            format.html { render :edit, status: :unprocessable_entity }
            format.json { render json: @ballot.errors, status: :unprocessable_entity }
          end
        elsif !@ballot.delete_requested && params[:choice]
          if @ballot.update(choice: params[:choice])
            format.html { redirect_back_or_to @voting, notice: "投票を受け付けました." }
            format.json { render :show, status: :ok, location: @ballot }
          else
            format.html { render :edit, status: :unprocessable_entity }
            format.json { render json: @ballot.errors, status: :unprocessable_entity }
          end
        end
      end
    end
  end

  # owner only
  def destroy
    authorize @ballot
    if @ballot.delivered
      BallotMailer.with(address: @ballot.voter, voting: @voting).ballot_deleted.deliver_later
    end
    @ballot.destroy!

    respond_to do |format|
      format.html { redirect_back_or_to voters_voting_path(@voting), notice: "参加者が削除されました." }
      format.json { head :no_content }
    end
  end

  # voter only
  def deliver
    if authorized_voter?
      BallotMailer.with(ballot: @ballot, exp: @voting.exp_at_vote, voting: @voting).get_ballot.deliver_later
      @ballot.update(delivered: true)
      if @ballot.save
        respond_to do |format|
          format.html { redirect_back_or_to @voting, notice: "発行されました. 数分以内にメールが届きます." }
          format.json { head :no_content }
        end
      end
    end
  end

  # voter only
  def redeliver
    if authorized_voter?
      BallotMailer.with(ballot: @ballot, exp: @voting.exp_at_vote, voting: @voting).renew_ballot.deliver_later
      @ballot.update(delivered: true)
      if @ballot.save
        respond_to do |format|
          format.html { redirect_back_or_to @voting, notice: "再発行されました. 数分以内にメールが届きます." }
          format.json { head :no_content }
        end
      end
    end
  end

  # owner only
  def deliver_from_owner
    authorize @ballot

    BallotMailer.with(ballot: @ballot, exp: @voting.exp_at_delivery, voting: @voting).ballot_from_owner.deliver_later
    @ballot.update(delivered: true)
    if @ballot.save
      respond_to do |format|
        format.html { redirect_back_or_to voters_voting_path(@voting), notice: "送信されました." }
        format.json { head :no_content }
      end
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
      params.require(:ballot).permit(:voting_id, :voter, :password_digest, :choice, :delete_requested, :exp)
    end
end
