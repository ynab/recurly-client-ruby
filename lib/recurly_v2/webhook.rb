module RecurlyV2
  # The Webhook class handles delegating the webhook request body to the appropriate
  # notification class. Notification classes enapsualte the supplied data, providing
  # access to account details, as well as subscription, invoice, and transaction
  # details where available.
  #
  # @example
  #   RecurlyV2::Webhook.parse(xml_body)  # => #<RecurlyV2::Webhook::NewAccountNotification ...>
  #
  #   notification = RecurlyV2::Webhook.parse(xml_body)
  #   case notification
  #   when RecurlyV2::Webhook::NewAccountNoficiation
  #     # A new account was created
  #     ...
  #   when RecurlyV2::Webhook::NewSubscriptionNotification
  #     # A new subscription was added
  #     ...
  #   when RecurlyV2::Webhook::SubscriptionNotification
  #     # A subscription-related notification was sent
  #     ...
  #   end
  module Webhook
    autoload :Notification,                             'recurly_v2/webhook/notification'
    autoload :AccountNotification,                      'recurly_v2/webhook/account_notification'
    autoload :SubscriptionNotification,                 'recurly_v2/webhook/subscription_notification'
    autoload :InvoiceNotification,                      'recurly_v2/webhook/invoice_notification'
    autoload :ItemNotification,                         'recurly_v2/webhook/item_notification'
    autoload :TransactionNotification,                  'recurly_v2/webhook/transaction_notification'
    autoload :DunningNotification,                      'recurly_v2/webhook/dunning_notification'
    autoload :CreditPaymentNotification,                'recurly_v2/webhook/credit_payment_notification'
    autoload :BillingInfoUpdatedNotification,           'recurly_v2/webhook/billing_info_updated_notification'
    autoload :BillingInfoUpdateFailedNotification,      'recurly_v2/webhook/billing_info_update_failed_notification'
    autoload :SubscriptionPausedNotification,           'recurly_v2/webhook/subscription_paused_notification'
    autoload :SubscriptionPauseCanceledNotification,    'recurly_v2/webhook/subscription_pause_canceled_notification'
    autoload :SubscriptionPauseModifiedNotification,    'recurly_v2/webhook/subscription_pause_modified_notification'
    autoload :PausedSubscriptionRenewalNotification,    'recurly_v2/webhook/paused_subscription_renewal_notification'
    autoload :SubscriptionResumedNotification,          'recurly_v2/webhook/subscription_resumed_notification'
    autoload :CanceledSubscriptionNotification,         'recurly_v2/webhook/canceled_subscription_notification'
    autoload :ScheduledSubscriptionPauseNotification,   'recurly_v2/webhook/scheduled_subscription_pause_notification'
    autoload :ScheduledSubscriptionUpdateNotification,  'recurly_v2/webhook/scheduled_subscription_update_notification'
    autoload :CanceledAccountNotification,              'recurly_v2/webhook/canceled_account_notification'
    autoload :ClosedInvoiceNotification,                'recurly_v2/webhook/closed_invoice_notification'
    autoload :ClosedCreditInvoiceNotification,          'recurly_v2/webhook/closed_credit_invoice_notification'
    autoload :NewCreditInvoiceNotification,             'recurly_v2/webhook/new_credit_invoice_notification'
    autoload :ProcessingCreditInvoiceNotification,      'recurly_v2/webhook/processing_credit_invoice_notification'
    autoload :ReopenedCreditInvoiceNotification,        'recurly_v2/webhook/reopened_credit_invoice_notification'
    autoload :VoidedCreditInvoiceNotification,          'recurly_v2/webhook/voided_credit_invoice_notification'
    autoload :NewCreditPaymentNotification,             'recurly_v2/webhook/new_credit_payment_notification'
    autoload :VoidedCreditPaymentNotification,          'recurly_v2/webhook/voided_credit_payment_notification'
    autoload :ExpiredSubscriptionNotification,          'recurly_v2/webhook/expired_subscription_notification'
    autoload :FailedPaymentNotification,                'recurly_v2/webhook/failed_payment_notification'
    autoload :NewAccountNotification,                   'recurly_v2/webhook/new_account_notification'
    autoload :UpdatedAccountNotification,               'recurly_v2/webhook/updated_account_notification'
    autoload :NewInvoiceNotification,                   'recurly_v2/webhook/new_invoice_notification'
    autoload :NewChargeInvoiceNotification,             'recurly_v2/webhook/new_charge_invoice_notification'
    autoload :ProcessingChargeInvoiceNotification,      'recurly_v2/webhook/processing_charge_invoice_notification'
    autoload :PastDueChargeInvoiceNotification,         'recurly_v2/webhook/past_due_charge_invoice_notification'
    autoload :PaidChargeInvoiceNotification,            'recurly_v2/webhook/paid_charge_invoice_notification'
    autoload :FailedChargeInvoiceNotification,          'recurly_v2/webhook/failed_charge_invoice_notification'
    autoload :ReopenedChargeInvoiceNotification,        'recurly_v2/webhook/reopened_charge_invoice_notification'
    autoload :NewSubscriptionNotification,              'recurly_v2/webhook/new_subscription_notification'
    autoload :PastDueInvoiceNotification,               'recurly_v2/webhook/past_due_invoice_notification'
    autoload :ReactivatedAccountNotification,           'recurly_v2/webhook/reactivated_account_notification'
    autoload :RenewedSubscriptionNotification,          'recurly_v2/webhook/renewed_subscription_notification'
    autoload :SuccessfulPaymentNotification,            'recurly_v2/webhook/successful_payment_notification'
    autoload :SuccessfulRefundNotification,             'recurly_v2/webhook/successful_refund_notification'
    autoload :UpdatedSubscriptionNotification,          'recurly_v2/webhook/updated_subscription_notification'
    autoload :VoidPaymentNotification,                  'recurly_v2/webhook/void_payment_notification'
    autoload :ProcessingPaymentNotification,            'recurly_v2/webhook/processing_payment_notification'
    autoload :ProcessingInvoiceNotification,            'recurly_v2/webhook/processing_invoice_notification'
    autoload :ScheduledPaymentNotification,             'recurly_v2/webhook/scheduled_payment_notification'
    autoload :NewDunningEventNotification,              'recurly_v2/webhook/new_dunning_event_notification'
    autoload :GiftCardNotification,                     'recurly_v2/webhook/gift_card_notification'
    autoload :PurchasedGiftCardNotification,            'recurly_v2/webhook/purchased_gift_card_notification'
    autoload :UpdatedGiftCardNotification,              'recurly_v2/webhook/updated_gift_card_notification'
    autoload :RegeneratedGiftCardNotification,          'recurly_v2/webhook/regenerated_gift_card_notification'
    autoload :CanceledGiftCardNotification,             'recurly_v2/webhook/canceled_gift_card_notification'
    autoload :RedeemedGiftCardNotification,             'recurly_v2/webhook/redeemed_gift_card_notification'
    autoload :UpdatedBalanceGiftCardNotification,       'recurly_v2/webhook/updated_balance_gift_card_notification'
    autoload :NewUsageNotification,                     'recurly_v2/webhook/new_usage_notification'
    autoload :TransactionAuthorizedNotification,        'recurly_v2/webhook/transaction_authorized_notification'
    autoload :LowBalanceGiftCardNotification,           'recurly_v2/webhook/low_balance_gift_card_notification'
    autoload :TransactionStatusUpdatedNotification,     'recurly_v2/webhook/transaction_status_updated_notification'
    autoload :UpdatedInvoiceNotification,               'recurly_v2/webhook/updated_invoice_notification'
    autoload :NewShippingAddressNotification,           'recurly_v2/webhook/new_shipping_address_notification'
    autoload :UpdatedShippingAddressNotification,       'recurly_v2/webhook/updated_shipping_address_notification'
    autoload :DeletedShippingAddressNotification,       'recurly_v2/webhook/deleted_shipping_address_notification'
    autoload :FraudInfoUpdatedNotification,             'recurly_v2/webhook/fraud_info_updated_notification'
    autoload :NewItemNotification,                      'recurly_v2/webhook/new_item_notification'
    autoload :UpdatedItemNotification,                  'recurly_v2/webhook/updated_item_notification'
    autoload :DeactivatedItemNotification,              'recurly_v2/webhook/deactivated_item_notification'
    autoload :ReactivatedItemNotification,              'recurly_v2/webhook/reactivated_item_notification'
    autoload :PrerenewalNotification,                   'recurly_v2/webhook/prerenewal_notification'

    # This exception is raised if the Webhook Notification initialization fails
    class NotificationError < Error
    end

    # @return [Resource] A notification.
    # @raise [NotificationError] For unknown or invalid notifications.
    def self.parse xml_body
      xml = XML.new xml_body
      class_name = Helper.classify xml.name

      if Webhook.const_defined?(class_name, false)
        klass = Webhook.const_get class_name
        klass.from_xml xml_body
      else
        raise NotificationError, "'#{class_name}' is not a recognized notification"
      end
    end
  end
end
