require_relative '../test-support'

module Skylab::Tabular::TestSupport

  describe "[tab] magnetics - surveyed page via mixed tuple stream" do

    TS_[ self ]
    use :memoizer_methods

    context "(non numeric)" do

      it "knows the number of nils" do

        colA, colB = _these_two_columns
        colA.number_of_nils == 2 || fail
        colB.number_of_nils.zero? || fail

        colA.number_of_cels == 5 || fail  # (sneak this in here)
        colB.number_of_cels == 5 || fail
      end

      it "knows the number of booleans" do

        colA, colB = _these_two_columns
        colA.number_of_booleans.zero? || fail
        colB.number_of_booleans == 2 || fail
      end

      it "knows the number of others" do

        colA, colB = _these_two_columns
        colA.number_of_others == 1 || fail
        colB.number_of_others.zero? || fail
      end

      it "knows the number of strings" do

        colA, colB = _these_two_columns
        colA.number_of_strings.zero? || fail
        colB.number_of_strings == 3 || fail
      end

      it "knows the number of symbols" do

        colA, colB = _these_two_columns
        colA.number_of_symbols == 2 || fail
        colB.number_of_symbols.zero? || fail
      end

      it "knows the number of blank strings" do
        _these_two_columns.last.number_of_blank_strings == 2 || fail
      end

      it "knows the number of zero-length strings" do
        _these_two_columns.last.number_of_zero_length_strings == 1 || fail
      end

      it "knows the width of the widest string" do
        _these_two_columns.last.width_of_widest_string == 7 || fail
      end

      shared_subject :_these_two_columns do

        a = []
        a << [ nil, " \t" ]
        a << [ :xx, true ]
        a << [ nil, " four  " ]
        a << [ :xx, false ]
        a << [ TS_, "" ]  # EMPTY_S_
        stats_via_these_ a
      end
    end

    context "(numeric)" do

      it "knows the number of numerics" do
        colA, colB = _these_two_columns
        colA.number_of_numerics == 5 || fail
        colB.number_of_numerics == 4 || fail
      end

      it "knows the number of nonzero floats" do
        colA, colB = _these_two_columns
        colA.number_of_nonzero_floats.zero? || fail
        colB.number_of_nonzero_floats == 2 || fail
      end

      it "knows the number of nonzero integers" do
        colA, colB = _these_two_columns
        colA.number_of_nonzero_integers == 3 || fail
        colB.number_of_nonzero_integers.zero? || fail
      end

      it "knows the number of negatives" do
        colA, colB = _these_two_columns
        colA.number_of_negatives == 1 || fail
        colB.number_of_negatives.zero? || fail
      end

      it "knows the number of zeros" do
        colA, colB = _these_two_columns
        colA.number_of_zeros == 2 || fail
        colB.number_of_zeros == 2 || fail
      end

      shared_subject :_these_two_columns do

        a = []
        a << [ 1,   2.0 ]
        a << [ 0,   false ]
        a << [ 0.0, 0.0 ]
        a << [ -5,  0 ]
        a << [ 7,   8.8 ]
        stats_via_these_ a
      end
    end

    def stats_via_these_ a

      _ = _same_pipe
      _st = Home_::Stream_[ a ]
      _surveyed_page = _[ _st ]
      _hi = _surveyed_page
      _hi.FIELD_SURVEYS
    end

    memoize :_same_pipe do
      Home_::Pipeline.define do |o|
        o << :SurveyedPage_via_MixedTupleStream
        # ..
      end
    end
  end
end
