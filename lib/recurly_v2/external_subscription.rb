module RecurlyV2
  class ExternalSubscription < Resource

    # @return [Account]
    belongs_to :account

    # @return [ExternalProductReference]
    belongs_to :external_product_reference

    # @return [ExternalInvoice]
    has_many :external_invoices

    # @return [ExternalPaymentPhase]
    has_many :external_payment_phases

    define_attribute_methods %w(
      account
      uuid
      external_id
      external_product_reference
      quantity
      activated_at
      expires_at
      created_at
      updated_at
      last_purchased
      auto_renew
      app_identifier
      state
      trial_started_at
      trial_ends_at
      canceled_at
      in_grace_period
      imported
      test
    )

    # We do not expose PUT or POST in the v2 API.
    protected(*%w(save save!))
    private_class_method(*%w(create! create))

    def get_external_payment_phases
      Pager.new(RecurlyV2::ExternalPaymentPhase, uri: "#{path}/external_payment_phases", parent: self)
    rescue RecurlyV2::API::UnprocessableEntity => e
      raise Invalid, e.message
    end

    def get_external_payment_phase(external_payment_phase_uuid)
      ExternalPaymentPhase.from_response API.get("#{path}/external_payment_phases/#{external_payment_phase_uuid}")
    rescue RecurlyV2::API::UnprocessableEntity => e
      raise Invalid, e.message
    end

    def self.find_by_external_id(external_id)
      self.find("external-id-#{external_id}")
    end

    def self.find_by_uuid(uuid)
      self.find("uuid-#{uuid}")
    end
  end
end
