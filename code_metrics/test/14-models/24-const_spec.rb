require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] magnetics (private) - const" do

    TS_[ self ]
    use :expect_emission_fail_early
    use :treemap_node  # for only one method

    it "loads" do
      _subject_module || fail
    end

    context "(the const scanner)" do

      it "works for \"qualified\" or not qualified const names" do

        ding = _sub_subject_via '::WibbleDibble::Wobble'
        dong = _sub_subject_via 'WibbleDibble::Wobble'

        ding.is_last && fail

        ding.was_absolute || fail
        dong.was_absolute && fail

        same = 'WibbleDibble'
        ding.gets_one == same || fail
        dong.gets_one == same || fail

        ding.is_last || fail
        dong.is_last || fail

        same = 'Wobble'
        ding.gets_one == same || fail
        dong.gets_one == same || fail

        ding.no_unparsed_exists || fail
        dong.no_unparsed_exists || fail
      end

      it "empty string" do
        _against EMPTY_S_
        _expect :error, :expression, :premature_end_of_string
      end

      it "ugly string" do
        _against "famShooozle Somewhere in la Mancha, in a place whose name I"
        _expect :error, :expression, :failed_to_parse_const do |y|
          y.first == 'failed to parse const (near "famShooozle [..]")' || fail
        end
      end

      it "pretty string then ugly string" do
        _against 'WhipporWhill001::eek'
        _expect :error, :expression, :failed_to_parse_const
      end

      def _against s
        call_by do
          _p = @EEFE_dispatcher.listener
          scn = _sub_subject_via s, & _p
          if scn
            __against_scanner scn
          else
            scn
          end
        end
        NIL
      end

      def __against_scanner scn
        debugging_a = []
        x = false
        begin
          if scn.no_unparsed_exists
            break
          end
          s = scn.gets_one
          if s
            debugging_a.push s
            redo
          end
          x = s
          break
        end while above
        x
      end

      def _expect * sym_a, & p

        expect_on_channel sym_a, & p
        expect_result false
      end

      def expression_agent
        __the_empty_expression_agent
      end
    end

    def __the_empty_expression_agent
      TestSupport_::THE_EMPTY_EXPRESSION_AGENT
    end

    def _sub_subject_via s, & p
      const_scanner_model.via_string s, & p
    end

    def _subject_module
      const_model
    end
  end
end
