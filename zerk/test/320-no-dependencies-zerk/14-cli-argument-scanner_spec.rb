require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] no deps - CLI argument scanner" do

    # exactly as #nodeps-spot-1

    TS_[ self ]
    use :no_dependencies_zerk

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

      it subdesc.after_not_parsing_the_primary_the_scanner_is_not_empty do
        after_not_parsing_the_primary_the_scanner_is_not_empty
      end

      def want_that_lines_express_appropriately y
        y == [ "does not look like primary: \"aa-zz\"" ] || fail
      end

      def expression_agent
        expression_agent_for_CLI
      end

      # --

      subcanon.write_definitions_into self

      def build_scanner & l
        _subject_module_via 'aa-zz', & l
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

      it subdesc.after_matching_the_primary_the_scanner_is_still_not_empty do
        after_matching_the_primary_the_scanner_is_still_not_empty
      end

      it subdesc.after_accepting_the_match_the_scanner_IS_empty do
        after_accepting_the_match_the_scanner_IS_empty
      end

      subcanon.write_definitions_into self

      def build_scanner
        _subject_module_via "-prim-1"
      end
    end

    canon.finish_canon  # just checks if we forgot any tests

    def _subject_module_via * s_a, & l
      scanner_class.narrator_for s_a, & l
    end

    def scanner_class
      subject_library_::CLI_ArgumentScanner
    end
  end
end
