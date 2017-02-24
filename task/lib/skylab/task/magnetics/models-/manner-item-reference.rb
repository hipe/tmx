
class Skylab::Task

  module Magnetics

    class Models_::Manner_ItemReference

      def initialize _MANNNER_sym, slot_sym  # the more specifics things earlier
        @manner_term_symbol = _MANNNER_sym
        @slot_term_symbol = slot_sym
      end

      p = Here_.upcase_const_string_via_snake_case_symbol_

      define_method :const do
        @___const ||= :"#{ p[ @slot_term_symbol ] }_as_#{ p[ @manner_term_symbol ] }"
      end

      def ivar
        @___ivar ||= :"@#{ @slot_term_symbol }"
      end

      attr_reader(
        :manner_term_symbol,
        :slot_term_symbol,
      )

      def category_symbol
        :manner
      end
    end
  end
end
