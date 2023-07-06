module RecurlyV2
  # Measured Units are used in RecurlyV2's usage-based billing feature.
  #
  # RecurlyV2 Documentation: https://dev.recurly.com/docs/measured-unit-object
  class MeasuredUnit < Resource
    define_attribute_methods %w(
      id
      name
      display_name
      description
      created_at
      updated_at
    )
    alias to_param id
  end
end
