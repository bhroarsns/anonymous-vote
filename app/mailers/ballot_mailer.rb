class BallotMailer < ApplicationMailer
  before_action :get_address_voting_title
  before_action :get_password_exp_start_deadline, only: [ :ballot_from_owner, :get_ballot, :renew_ballot ]
  before_action :get_owner_name, only: [ :ballot_from_owner, :ballot_deleted, :delete_requested ]

  include VotingsHelper

  # require :address, :password, :exp, :voting
  def ballot_from_owner
    @link_type = link_type(@voting)
    mail(to: @address, subject: "「#{@title}」の#{@link_type}が届きました")
  end

  # require :address, :password, :exp, :voting
  def get_ballot
    mail(to: @address, subject: "「#{@title}」の投票リンクが発行されました")
  end

  # require :address, :password, :exp, :voting
  def renew_ballot
    mail(to: @address, subject: "「#{@title}」の投票リンクが再発行されました")
  end

  # require :address, :voting, :changes
  def voting_changed
    @changes = params[:changes]
    @title = @changes[:title] ? @changes[:title][0] : @title
    mail(to: @address, subject: "「#{@title}」の設定が変更されました")
  end

  # require :address, :voting
  def ballot_deleted
    mail(to: @address, subject: "「#{@title}」の投票権が削除されました")
  end

  # require :address, :voting
  def delete_requested
    @owner_address = @voting.user.email
    mail(to: @owner_address, subject: "「#{@title}」で投票権の取り消し申請がありました")
  end

  private
    def get_address_voting_title
      @address = params[:address]
      @voting = params[:voting]
      @title = @voting.title
    end
    
    def get_password_exp_start_deadline
      @password = params[:password]
      @exp = params[:exp]
      @start = @voting.start
      @deadline = @voting.deadline
    end

    def get_owner_name
      @owner_name = @voting.user.name
    end
end
