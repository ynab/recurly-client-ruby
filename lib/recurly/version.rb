module Recurly
  module Version
    VERSION = "2.19.14"

    class << self
      def inspect
        VERSION.dup
      end
      alias to_s inspect
    end
  end
end
