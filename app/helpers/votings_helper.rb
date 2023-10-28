module VotingsHelper
  def format_choice(choice)
    choice ||= "未投票"
  end

  def description_lines(description)
    description.split("\n")
  end

  def name_of_ballot(voting)
    if voting.mode == "default"
      "投票用リンク"
    elsif voting.mode == "security"
      "招待リンク"
    end
  end

  def confirm_message_on_change(voting)
    if voting.report_change_on_start_and_deadline
      if voting.report_change_on_title_and_description
        "投票開始時刻、投票終了時刻を変更した場合、リンク送信済みの参加者には通知が送られます。\nまた、投票期間中のため、タイトル、説明を説明を更新した場合も通知が送られます。\n本当に変更しますか？"
      else
        "投票開始時刻、投票終了時刻を変更した場合、リンク送信済みの参加者には通知が送られます。\n本当に変更しますか？"
      end
    end
  end
end
