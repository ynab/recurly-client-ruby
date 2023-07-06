module RecurlyV2
  module Webhook
    # The AccountNotification class provides a generic interface
    # for account-related webhook notifications.
    class AccountNotification < Notification
      # @return [Account]
      has_one :account

      # @return [ShippingAddress]
      has_one :shipping_address
    end
  end
end
