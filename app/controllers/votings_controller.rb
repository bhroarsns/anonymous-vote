class VotingsController < ApplicationController
  before_action :set_voting, only: %i[ show edit update destroy ]

  # GET /votings or /votings.json
  def index
    @votings = Voting.all
  end

  # GET /votings/1 or /votings/1.json
  def show
  end

  # GET /votings/new
  def new
    @voting = Voting.new
  end

  # GET /votings/1/edit
  def edit
  end

  # POST /votings or /votings.json
  def create
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

  # PATCH/PUT /votings/1 or /votings/1.json
  def update
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

  # DELETE /votings/1 or /votings/1.json
  def destroy
    @voting.destroy!

    respond_to do |format|
      format.html { redirect_to mypage_path, notice: "Voting was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_voting
      @voting = Voting.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def voting_params
      params.require(:voting).permit(:title, :description, :choices, :deadline, :mode, :config).merge(user_id: current_user.id)
    end
end
