module Skylab::BeautySalon

  class CrazyTownMagnetics_::NodeProcessor_via_Module

    # see "declarative (structural) grammar reflection" :[#021.I]

    # implementation-wise, we employ the [#ze-051] "operator branch" pattern
    #
    #   - superficially simliar to [#ze-051.2] but it's simple enough we
    #     might as well re-write it. (we don't take an index-first approach
    #     here.)

    class << self
      alias_method :[], :new
      private :new
    end  # >>

    # -

      def initialize mod
        @_do_index = true
        @_valid_const_via_normal_name_symbol = {}
        @module = mod
      end

      def procure ref_sym, & listener
        cls = lookup_softly ref_sym
        if cls
          cls
        else
          __when_not_found listener, ref_sym
        end
      end

      def lookup_softly ref_sym
        c = __valid_const_via_normal_name_symbol ref_sym
        if c
          _dereference_via_internal_key c
        end
      end

      def __when_not_found listener, ref_sym

        me = self
        listener.call :error, :expression, :parse_error do |y|
          me.__levenshtein_into y, ref_sym
        end
        UNABLE_
      end

      def __levenshtein_into y, ick_sym

        @_do_index && __index_all

        _sym_a = @_valid_const_via_normal_name_symbol.keys

        _s_a = _sym_a.map { |sym| "'#{ sym }'" }

        y << %(currently we don't yet have metadata for grammar symbol '#{ ick_sym }'.)
        y << "(currently we have it for #{ Common_::Oxford_and[ _s_a ] }.)"
      end

      def __valid_const_via_normal_name_symbol ref_sym
        c = @_valid_const_via_normal_name_symbol[ ref_sym ]
        if c
          c
        else
          __valid_const_via_lookup_and_cache ref_sym
        end
      end

      def __valid_const_via_lookup_and_cache ref_sym
        c_s = __internal_key_via_normal_name_symbol ref_sym
        if @module.const_defined? c_s, false
          c = c_s.intern
          @_valid_const_via_normal_name_symbol[ ref_sym ] = c
          c
        end
      end

      def __index_all

        @_do_index = false

        @module.constants.each do |c|

          _ref_sym = __normal_symbol_name_via_internal_key c

          # any of these that we have already seen we are creating
          # redundantly (because we don't index early). ich muss sein

          @_valid_const_via_normal_name_symbol[ _ref_sym ] = c
        end
      end

      def _dereference_via_internal_key c
        @module.const_get c, false
      end

      def __internal_key_via_normal_name_symbol ref_sym
        Common_::Name.via_variegated_symbol( ref_sym ).as_camelcase_const_string
      end

      def __normal_symbol_name_via_internal_key c
        Common_::Name.via_const_symbol( c ).as_variegated_symbol
      end

    # -

    # ==

    # ==
    # ==
  end
end
# #broke-out from "selector via string"
