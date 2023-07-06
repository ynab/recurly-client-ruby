module RecurlyV2
  class Tier < Resource

    belongs_to :add_on
    belongs_to :subscription_add_on

    define_attribute_methods %w(
      ending_quantity
      unit_amount_in_cents
    )

    def xml_keys
      attributes.keys
    end

    embedded! true
  end
end
