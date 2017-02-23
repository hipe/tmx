class Skylab::Task

  module Magnetics

    class Models_::Unassociated_ItemTicket

      def initialize sym
        @term_symbol = sym
      end

      attr_reader(
        :term_symbol,
      )

      def category_symbol
        :unassociated
      end
    end
  end
end
