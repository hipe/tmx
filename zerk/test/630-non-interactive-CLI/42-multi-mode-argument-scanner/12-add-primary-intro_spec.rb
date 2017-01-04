require_relative '../../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI - argument scanner - add primary" do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI_argument_scanner

    it "if your `add_primary` results in false-ish, normal execution is circumvented." do

      # (#scn-coverpoint-1-A)

      yay = nil

      as = define_by_ do |o|

        o.add_primary :helbo do
          yay = :_hi_
          false
        end

        o.user_scanner real_scanner_for_( "--helbo", "-doopie" )
      end

      h = {
        doopie: :_no_see_,
      }

      _route = as.match_branch :primary, :against_hash, h
      _route == false || fail

      yay == :_hi_ || fail
    end

    it "if your `add_primary` results in true-ish, \"normal\" flow of execution." do

      # NOTE this also tests fuzzy-ness for perhaps the first time :/

      # (#scn-coverpoint-1-B)

      v_count = 0

      as = define_by_ do |o|

        o.add_primary :verpose do
          v_count += 1
          as.advance_one  # NOTE infinite loop otherwise
          true
        end

        o.user_scanner real_scanner_for_( "--verpose", "-dopey", "-v", "-flopey" )
      end

      h = {
        dopey: :_hi_1_,
        flopey: :_hi_2_,
      }

      _sym = branch_value_via_match_primary_against_ as, h
      _sym == :_hi_1_ || fail

      v_count == 1 || fail

      as.advance_one

      _sym = branch_value_via_match_primary_against_ as, h
      _sym == :_hi_2_ || fail

      v_count == 2 || fail

      as.advance_one
      as.no_unparsed_exists || fail
    end

    it "fuzzy" do

      yay = nil

      as = define_by_ do |o|

        o.add_primary :helbo do
          yay = :_hi_
          NIL  # stop parsing (nil not false to be cheeky)
        end

        o.user_scanner real_scanner_for_( "-he", "doopie" )
      end

      _x = branch_value_via_match_primary_against_ as, {}  # EMPTY_H_
      _x == NIL || fail

      yay == :_hi_ || fail
    end

    context "fuzzy ambi" do

      it "fails" do
        _message_lines || fail
      end

      it "says ambiguous" do
        _message_lines.first == "ambiguous primary \"-he\"." || fail
      end

      it "says \"did you mean..\"" do
        _message_lines.last == 'did you mean "-helbo" or "-heffer" or "-here-there"?' || fail
      end

      shared_subject :_message_lines do

        spy = begin_emission_spy_

        as = define_by_ do |o|

          o.add_primary :helbo do
            TS_._NEVER_CALL
          end

          o.user_scanner real_scanner_for_( "-he", "doopie" )

          o.emit_into spy.listener
        end

        h = {
          heffer: :_no_see_,
          here_there: :_no_see_,
          but_not_this: :_no_see_,
        }

        y = nil
        spy.expect :error, :expression, :parse_error, :ambiguous do |y_|
          y = y_
        end

        spy.call_by do
          branch_value_via_match_primary_against_ as, h
        end

        _x = spy.execute_under self
        _x == false || fail
        y
      end
    end
  end
end
