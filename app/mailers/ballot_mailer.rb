class BallotMailer < ApplicationMailer
  def ballot
    voting = params[:voting]
    ballot = params[:ballot]
    password = ballot.renew_password(params[:exp])

    @address = ballot[:voter]
    @url = voting_path(@voting, v: @address, p: password)
    @exp = params[:exp]

    mail(to: @address, subject: "投票用紙が届きました[#{@voting.title}]")
  end
end
