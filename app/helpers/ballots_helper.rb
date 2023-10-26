module BallotsHelper
  def delivery_status(delivered)
    if delivered
      "Delivered"
    else
      "Not Delivered"
    end
  end
end
