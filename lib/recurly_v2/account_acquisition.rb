module RecurlyV2
  # RecurlyV2 Documentation: https://dev.recurly.com/docs/create-account-acquisition
  class AccountAcquisition < Resource
    # @return [Account]
    belongs_to :account

    define_attribute_methods %w(
      cost_in_cents
      currency
      channel
      subchannel
      campaign
    )

    def self.member_name
      "acquisition"
    end

    def self.xml_root_key
      "account_acquisition"
    end

    # Acquisitions are only writeable and readable through {Account} instances.
    embedded!
    private_class_method :find
  end
end
