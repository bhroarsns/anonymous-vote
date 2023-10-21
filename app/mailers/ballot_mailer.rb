class BallotMailer < ApplicationMailer
  def ballot
    ballot = params[:ballot]
    password = ballot.renew_password(params[:exp])

    @address = ballot[:voter]
    @url = "http://localhost:3000/votings/#{ballot[:voting_id]}?v=#{@address}&p=#{password}"
    @exp = params[:exp]

    mail(to: @address, subject: 'Ballot arrived')
  end
end
