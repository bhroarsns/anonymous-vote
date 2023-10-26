class BallotMailer < ApplicationMailer
  before_action :set_voting_title
  before_action :set_ballot_address, except: :ballot_deleted
  before_action :set_exp_password_url_start_deadline, only: [ :ballot_from_owner, :get_ballot, :renew_ballot ]

  def ballot_from_owner
    @owner = @voting.user.name
    @name_of_ballot = @exp ? "投票リンク" : "招待"

    mail(to: @address, subject: "「#{@title}」の#{@name_of_ballot}が届きました")
  end

  def get_ballot
    mail(to: @address, subject: "「#{@title}」の投票リンクが発行されました")
  end

  def renew_ballot
    mail(to: @address, subject: "「#{@title}」の投票リンクが再発行されました")
  end

  def voting_changed
    @changes = params[:changes]
    mail(to: @address, subject: "「#{@title}」の設定が変更されました")
  end

  def ballot_deleted
    @address = params[:address]
    @owner = @voting.user.name
    @owner_address = @voting.user.email
    mail(to: @address, subject: "「#{@title}」の投票権が削除されました")
  end

  def delete_requested
    @owner = @voting.user.name
    @owner_address = @voting.user.email
    mail(to: @owner_address, subject: "「#{@title}」で投票権の取り消し申請がありました")
  end

  private
    def set_voting_title
      @voting = params[:voting]
      @title = @voting.title
    end

    def set_ballot_address
      @ballot = params[:ballot]
      @address = @ballot[:voter]
    end

    def set_exp_password_url_start_deadline
      @password = @ballot.renew_password(params[:exp])
      @exp = params[:exp]
      @url = voting_url(@voting, v: @address, p: @password)
      @url_not_for_me = voting_url(@voting, v: @address, p: @password, not_for_me: true)
      @start = @voting.start
      @deadline = @voting.deadline
    end
end
