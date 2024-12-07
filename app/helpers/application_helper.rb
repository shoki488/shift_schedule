module ApplicationHelper
  def bootstrap_alert(key)
    case key.to_s
    when "notice"
      "success"
    when "error"
      "danger"
    end
  end
end
