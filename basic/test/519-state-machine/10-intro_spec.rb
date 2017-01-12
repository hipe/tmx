require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] state" do

    TS_[ self ]
    use :memoizer_methods
    use :expect_event

    shared_subject :_state_machine do

      # (based off of the frontier production use-case)

      _LONG_RX___ = /\A
        --
        (?<switch> [a-zA-Z0-9]+ (?:-[a-zA-Z0-9]+)* )
        (?: = (?<arg> .+ ) )?
      \z/x

      _SHORT_RX___ = /\A
        -
        (?<switch> [a-zA-Z0-9] )
        (?<arg> [^=]+ )?
      \z/x

      pair = -> v_x=nil, n_x=nil do
        Common_::Pair.via_value_and_name v_x, n_x
      end

      o = Home_::StateMachine.begin_definition

      o.add_state :beginning,
        :can_transition_to, [ :long_switch ]

      o.add_state :after_a_pair,
        :can_transition_to, [ :short_switch, :long_switch, :ending ]

      o.add_state :long_switch,
        :entered_by_regex, _LONG_RX___,
        :on_entry, -> sm do
          sw, arg = sm.user_matchdata.captures

          sm.downstream << pair[ sw, :long_switch ]

          if arg
            sm.downstream << pair[ arg, :value ]
            :after_a_pair
          else
            :value
          end
        end

      o.add_state :short_switch,
        :entered_by_regex, _SHORT_RX___,
        :on_entry, -> sm do
          sw, arg = sm.user_matchdata.captures

          sm.downstream << pair[ sw, :short_switch ]

          if arg
            sm.downstream << pair[ arg, :value ]
            :after_a_pair
          else
            :value
          end
        end

      o.add_state :value,
        :entered_by, -> st do
          if st.unparsed_exists
            st
          end
        end,
        :on_entry, -> sm do

          sm.downstream << pair[ sm.user_matchdata.gets_one, :value ]

          :after_a_pair
        end

      o.add_state :ending,
        :entered_by, -> _st do

          # any state that indicated this as a possible next
          # state may enter without barrier from this state

          :_trueish_
        end,

        :on_entry, -> sm do
          sm.receive_end_of_solution  # declare that there is no next state
        end

      o.finish
    end

    it "builds" do
      _state_machine || fail
    end

    it "no input" do

      _against Common_::Polymorphic_Stream.the_empty_polymorphic_stream

      _expect_failed_with "expecting long switch at end of input"
    end

    it "bad input " do

      st = _upstream '-foo', 'bar'
      _against st
      _expect_failed_with 'expecting long switch at "-foo"'
      st.current_index.should be_zero
    end

    it "one token of good input - complains about missing next token" do

      st = _upstream '--foo'
      _against st
      _expect_failed_with "expecting value at end of input"
      st.current_index.should eql 1
    end

    it "two good tokens of input" do

      st = _upstream '--foo', 'bar'
      _against st
      _expect_same_result
      st.current_index.should eql 2
    end

    it "any state transition can write N number of output nodes" do

      # .. we can output multiple nodes of our "parse tree" from one state

      st = _upstream '--foo=bar'
      _against st
      _expect_same_result
      st.current_index.should eql 1
    end

    it "etc. pursuant to particular state machine it stops at unparasables" do

      st = _upstream '--foo=bar', '-bbaz', '-b', 'baz', 'stops here'
      _against st

      a = @result
      a.map( & :name_x ).should eql(
        [ :long_switch, :value, :short_switch, :value, :short_switch, :value ] )

      a.map( & :value_x ).should eql(
        %w( foo bar b baz b baz ) )

      st.current_index.should eql 4
    end

    def _upstream * s_a

      Common_::Polymorphic_Stream.via_array s_a
    end

    def _against st

      _sm = _state_machine
      _p = handle_event_selectively_
      @result = _sm.solve_against st, & _p
      NIL
    end

    def _expect_failed_with s

      _em = expect_not_OK_event :no_available_state_transition

      black_and_white( _em.cached_event_value ).should eql s

      expect_failed
    end

    def _expect_same_result

      expect_no_events

      a = @result

      a.length.should eql 2

      a.first.name_x.should eql :long_switch
      a.first.value_x.should eql 'foo'

      a.last.name_x.should eql :value
      a.last.value_x.should eql 'bar'
    end
  end
end
