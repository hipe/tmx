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

      # (GONE at #history-A.1)

      it subdesc.after_not_parsing_the_primary_the_scanner_is_not_empty do
        after_not_parsing_the_primary_the_scanner_is_not_empty
      end

      # --

      subcanon.write_definitions_into self

      def want_that_lines_express_appropriately y
        y == [ "does not look like primary: :_not_a_primary_" ] || fail
      end

      def expression_agent
        expression_agent_for_API
      end

      def build_scanner & l

        # pretty awful - we don't actually want our implementation to bother
        # checking if every primary is well-shaped; (in API what would this
        # mean? that head is a symbol?) but nonetheless we want to exercise
        # the machinery that ensure that if it were possible to fail to parse
        # a primary shape, it would act like other modality adaptations.

        nar = _subject_module_via :_not_a_primary_, & l

        mas = nar.instance_variable_get :@modality_adapter_scanner

        mas = mas.send :dup  # can't hack singleton class of frozen

        class << mas
          alias_method :__the_worst_thing_ever, :_match_primary_shaped_token_
          def _match_primary_shaped_token_
            if :_not_a_primary_ == @token_scanner.head_as_is
              NOTHING_
            else
              __the_worst_thing_ever
            end
          end
        end  # >>

        nar.class.new nar.listener, mas
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
        _subject_module_via :prim_1
      end
    end

    canon.finish_canon  # just checks if we forgot any tests

    def _subject_module_via * s_a, & l
      scanner_class.narrator_for s_a, & l
    end

    def scanner_class
      # TS_::No_Dependencies_Zerk::Argument_scanner_for_testing[]
      subject_library_::API_ArgumentScanner
    end
  end
end
# #history-A.1: during 2nd wave, some tests removed
# (this file referenced elsewhere as #nodeps-spot-1)
