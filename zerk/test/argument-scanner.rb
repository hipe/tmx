module Skylab::Zerk::TestSupport

  module Argument_Scanner

    def self.[] tcc
      tcc.include self
    end

    # -

      def ts_
        TS_::Argument_Scanner
      end

      def lib_
        Home_::ArgumentScanner
      end

    # -

    # ==

    Same__ = ::Class.new

    class Bread < Same__

      PRIMARIES = {
        baking_temp: :one_argument,
        organic: :boolean,
        sprouted: :boolean,
      }

      attr_reader(
        :baking_temp,
        :organic,
        :sprouted,
      )
    end

    class PeanutButter < Same__

      PRIMARIES = {
        brand_name: :one_argument,
        crunchy: :boolean,
        organic: :boolean,
      }

      attr_reader(
        :brand_name,
        :crunchy,
        :organic,
      )
    end

    class Same__

      # develop a simple, local meta-primary system of two types: "boolean"
      # and "one argument". sub-classes can define their primaries in terms
      # of these types and they will be parsed appropriately. in practice,
      # at writing we don't use such a system for lack of want; but the
      # main objective of this didactic is to exemplify a way to expose
      # an operator's primaries. (and look how clear the sub-classes are.)

      def initialize fake_as
        @argument_scanner = fake_as
      end

      def at_from_syntaxish wrapped_value
        send TYPES___.fetch wrapped_value.branch_item_value
      end

      TYPES___ = {
        boolean: :__parse_boolean,
        one_argument: :__parse_one_argument,
      }

      def __parse_boolean
        _ivar = _parse_ivar
        instance_variable_set _ivar, true
        ACHIEVED_
      end

      def __parse_one_argument
        _ivar = _parse_ivar
        _kn = @argument_scanner.parse_primary_value
        instance_variable_set _ivar, _kn.value
        ACHIEVED_
      end

      def _parse_ivar
        _sym = :"@#{ @argument_scanner.current_primary_symbol }"
        @argument_scanner.advance_one
        _sym
      end

      def feature_branch
        @___fb ||= Home_::ArgumentScanner::FeatureBranch_via_Hash[ self.class::PRIMARIES ]
      end
    end

    # ==
  end
end
# #history: abstracted from test file
