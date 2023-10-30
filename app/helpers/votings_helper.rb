module VotingsHelper
  def format_choice(choice)
    choice ||= "未投票"
  end

  def description_lines(description)
    description.split("\n")
  end

  def link_type(voting)
    if voting.mode == "default"
      "投票用リンク"
    elsif voting.mode == "security"
      "招待リンク"
    end
  end

  def confirm_message_on_change(voting)
    msg = voting.config_change_reports[:message]
    if msg
      msg + "\n本当に変更しますか？"
    end
  end
end
