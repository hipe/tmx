require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] no deps - API argument scanner" do

    TS_[ self ]
    use :no_dependencies_zerk

    # for [#051.1] the no-dependencies file

    # we're experimenting with a new style (to us) of effecting a "canon".
    # this crunchy style is probably not going to stick.
    # it's just here to get us off the ground.

    desc, canon = begin_scanner_canon

    context "the empty scanner" do

      it desc.the_empty_scanner_knows_it_is_empty do
        the_empty_scanner_knows_it_is_empty
      end

      canon.write_definitions_into self

      def build_scanner
        _subject_module_via
      end
    end

    context "the scanner whose head is not a primary" do

      subdesc, subcanon = canon.subcanon :subcanon_for_non_primary_head

      # --

      it subdesc.at_the_beginning_the_scanner_knows_it_has_some_unparsed do
        at_the_beginning_the_scanner_knows_it_has_some_unparsed
      end

      it subdesc.the_scanner_does_not_parse_the_primary do
        the_scanner_does_not_parse_the_primary
      end

      it subdesc.the_scanner_emits_that_it_did_not_parse_the_primary do
        the_scanner_emits_that_it_did_not_parse_the_primary
      end

      it subdesc.attempting_to_read_the_current_primary_symbol_raises do
        attempting_to_read_the_current_primary_symbol_raises
      end

      it subdesc.after_not_parsing_the_primary_the_scanner_is_not_empty do
        after_not_parsing_the_primary_the_scanner_is_not_empty
      end

      # --

      subcanon.write_definitions_into self

      def expect_that_lines_express_appropriately y
        y == [ "does not look like a primary: :_not_a_primary_" ] || fail
      end

      def expression_agent
        TestSupport_::THE_EMPTY_EXPRESSION_AGENT
      end

      def build_scanner & l
        _subject_module_via :_not_a_primary_, & l
      end
    end

    context "the scanner that has only a primary" do

      subdesc, subcanon = canon.subcanon :subcanon_for_primary_head

      it subdesc.at_the_beginning_the_scanner_knows_it_has_some_unparsed do
        at_the_beginning_the_scanner_knows_it_has_some_unparsed
      end

      it subdesc.the_scanner_parses_the_primary do
        the_scanner_parses_the_primary
      end

      it subdesc.after_parsing_the_primary_the_scanner_knows_it_is_empty do
        after_parsing_the_primary_the_scanner_knows_it_is_empty
      end

      subcanon.write_definitions_into self

      def build_scanner
        _subject_module_via :prim_1
      end
    end

    canon.finish_canon  # just checks if we forgot any tests

    def _subject_module_via * s_a, & l
      scanner_class.new s_a, & l
    end

    def scanner_class
      TS_::No_Dependencies_Zerk::Argument_scanner_for_testing[]
    end
  end
end
# (this file referenced elsewhere as #nodeps-spot-1)
