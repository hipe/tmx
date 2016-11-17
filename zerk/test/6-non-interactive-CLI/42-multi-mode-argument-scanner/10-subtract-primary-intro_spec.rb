require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] niCLI - multi-mode argument scanner - subtract primary" do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI_argument_scanner

    context "`subtract_primary`" do

      it "fails when you try to parse a subtracted primary" do
        _message_lines || fail
      end

      it "first line - acts like it dosn't recognize it" do
        _ = _message_lines.first
        _ == "unknown primary: \"-cant-touch-this\"" || fail
      end

      it "second line - offers \"did you mean..\"" do
        _ = _message_lines.last
        _ == "expecting { -hi }" || fail
      end

      shared_subject :_message_lines do

        spy = begin_emission_spy_

        as = define_by_ do |o|

          o.subtract_primary :cant_touch_this

          o.user_scanner real_scanner_for_( "-hi", "-cant-touch-this" )

          o.emit_into spy.listener
        end

        h = { hi: :_was_hi_, cant_touch_this: :_no_see_ }

        _x = as.branch_value_via_match_primary_against h
        _x == :_was_hi_ || fail

        as.advance_one

        spy.call_by do

          as.branch_value_via_match_primary_against h
        end

        y = nil
        spy.expect :error, :expression, :parse_error, :subtracted_primary_was_referenced do |y_|
          y = y_
        end

        _sym = spy.execute_under self

        _sym == false || fail
        y
      end
    end

    it "subtract primary (but add default)" do

      as = define_by_ do |o|

        o.subtract_primary :cant_touch_this_either, :zazlow

        o.user_scanner real_scanner_for_( "-joopie", "doopie" )
      end

      h = { cant_touch_this_either: :_hi_1_, joopie: :_hi_2_ }

      _m = as.branch_value_via_match_primary_against h
      _m == :_hi_1_ || fail

      as.advance_one

      _ = as.parse_primary_value :must_be_trueish
      _ == :zazlow || fail

      _m = as.branch_value_via_match_primary_against h
      _m == :_hi_2_ || fail

      as.advance_one

      as.head_as_is == "doopie" || fail

      as.advance_one

      as.no_unparsed_exists || fail
    end
  end
end
