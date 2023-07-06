module RecurlyV2
  # Delivery objects are only used with GiftCards.
  #
  # RecurlyV2 Documentation: https://dev.recurly.com/docs/gift-card-object
  class Delivery < Resource
    # @return [Address, nil]
    has_one :address

    define_attribute_methods %w(
      deliver_at
      email_address
      first_name
      gifter_name
      last_name
      method
      personal_message
    )
  end
end
