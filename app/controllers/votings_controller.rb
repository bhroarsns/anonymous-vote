class VotingsController < ApplicationController
  before_action :set_voting, only: %i[ show edit update destroy ]

  # (method: GET) Show voting page via votings/{uuid}
  def show
  end

  # (method: GET) Show voting creation page via votings/new
  def new
    @voting = Voting.new
  end

  # (method: POST) Create voting with params
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

  # (method: GET) Show voting edit page via votings/edit
  def edit
  end

  # (method: PUT/PATCH) Edit voting with params
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

  # (method: DELETE) Delete voting
  def destroy
    @voting.destroy!

    respond_to do |format|
      # redirect to mypage because there is no routing GET "/votings"
      format.html { redirect_to mypage_path, notice: "Voting was successfully destroyed." }
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
