module Recurly
  module Version
    VERSION = "2.19.6"

    class << self
      def inspect
        VERSION.dup
      end
      alias to_s inspect
    end
  end
end
