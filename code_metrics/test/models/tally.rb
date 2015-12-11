module Skylab::CodeMetrics::TestSupport

  module Models::Tally::Magnetics

    def self.[] tcc

      tcc.include self
    end

    # -
      def magnetics_module_
        Home_::Models_::Tally::Magnetics_
      end
    # -
  end
end
