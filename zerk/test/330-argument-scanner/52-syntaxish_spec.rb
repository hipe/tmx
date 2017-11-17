require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] argument scanner - syntaxish choices" do

    # :#a.s-coverpoint-2

    TS_[ self ]
    use :memoizer_methods
    use :argument_scanner

    it "loads" do
      _subject_module
    end

    # -

      it "builds" do
        _subject
      end

      context "the parse" do

        it "parses without failing" do
          _custom_tuple || fail
        end

        it "reports that it succeeded by resulting in true" do
          _custom_tuple.fetch( 0 ) == true || fail
        end

        it "wrote the values" do
          o = _custom_tuple.fetch 1  # bread op
          o.baking_temp == 378 || fail
          o.organic || fail
          o.sprouted || fail
        end

        it "no unparsed exists at the end" do
          _custom_tuple.fetch( 2 ).no_unparsed_exists || fail
        end

        shared_subject :_custom_tuple do

          _a = [ :baking_temp, 378, :organic, :sprouted ]

          ascn = Home_::API::ArgumentScanner.via_array _a, & Want_no_emission_

          bread_op = ts_::Bread.new ascn

          # ~( confirm that the values are this way before

          bread_op.baking_temp && fail
          bread_op.organic && fail
          bread_op.sprouted && fail

          # )~

          _x = _subject.parse_all_into_from bread_op, ascn

          [ _x, bread_op, ascn ]
        end
      end

      shared_subject :_subject do

        _fb = lib_::FeatureBranch_via_Hash[ ts_::Bread::PRIMARIES ]

        _subject_module.via_feature_branch _fb
      end

    # -

    def _subject_module
      Home_::ArgumentScanner::Syntaxish
    end
  end
end
