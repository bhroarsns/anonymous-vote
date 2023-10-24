module VotingsHelper
  def format_choice(choice)
    choice ||= "未投票"
  end

  def name_of_ballot(voting)
    if voting.mode == "default"
      "投票用リンク"
    elsif voting.mode == "security"
      "招待リンク"
    end
  end
end
