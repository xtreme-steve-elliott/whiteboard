module ItemHelper

  def date_label(item)
    if item.date.present? && (item.kind == "Event" || item.date > Date.today)
      Date::DAYNAMES[item.date.wday].to_s + ": "
    end
  end
end
