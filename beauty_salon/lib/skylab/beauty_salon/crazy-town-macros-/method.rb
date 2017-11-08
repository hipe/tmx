# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownMacros_::Method
    # -

      include Home_::MethodsForUserOfMacroParsingIdioms

      def initialize listener, scn
        init_macro_parsing_idioms listener, scn
      end

      def _validate_
        self  # (we do all our parsing lazily)
      end

      def unsanitized_before_string
        send( @_UBS ||= :__UBS_initially )
      end

      def __UBS_initially
        s = if __parse_delimiter
          __parse_unsanitized_before_string
        end
        if s
          @__UBS_value = s
          send( @_UBS = :__UBS_subsequently )
        else
          @_UBS = :_TAINTED ; UNABLE_
        end
      end

      def __UBS_subsequently
        @__UBS_value
      end

      def __parse_unsanitized_before_string
        curate_via_regex @__delimiter_regex, :unsanitized_before_string
      end

      def __parse_delimiter
        s = curate_one_of_these ':', '/', :delimiter  # etc
        if s
          @DELIMITER = s
          @__delimiter_regex = %r([^#{ s }]+)  # be careful
          ACHIEVED_
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    # -

    # ==
    # ==
  end
end
# #born.
