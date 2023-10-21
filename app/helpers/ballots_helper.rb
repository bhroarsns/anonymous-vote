module BallotsHelper
  def delivery_status(is_delivered)
    if is_delivered
      "Delivered"
    else
      "Not Delivered"
    end
  end
end
