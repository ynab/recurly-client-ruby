module RecurlyV2
  # The exception class from which all RecurlyV2 exceptions inherit.
  class Error < StandardError
    def set_message message
      @message = message
    end

    # @return [String]
    def to_s
      defined? @message and @message or super
    end
  end
end