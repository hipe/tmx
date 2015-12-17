module Skylab::Callback::TestSupport

  module Future_Expect

    # simplify event testing and (with "future") get immediate response
    #
    # NOTE - before you do any feature adding or maintence to this file,
    # look for ways to integrate it with 'expect-event'. as it is, it is
    # so minimal that we have left it separate. but since its inception
    # we have overhauled "expect event" so it is now fresher than this.
    # (and there is certainly conceptual redundancy between the two.)

    def self.[] tcc
      tcc.include self ; nil
    end

    def future_expect * a, & p
      _add_future_expect a, & p
    end

    def future_expect_only * a, & p
      _add_future_expect a, & p
      future_expect_no_more
    end

    def _add_future_expect a, & p
      a.push p
      ( @_future_expect_queue ||= [] ).push a ; nil
    end

    def future_expect_no_more
      ( @_future_expect_queue ||= [] ).push false ; nil
    end

    def past_expect_eventually * i_a, & ev_p

      em_a = past_emissions.all_on_channel i_a
      case 1 <=> em_a.length
      when 0
        em = em_a.fetch 0
        if ev_p
          Assert_procs__[ em.event_proc, em.category, ev_p ]
        else
          em
        end
      when -1
        fail Say_expected_one_thing_had_many_things__[ i_a, em_a.length ]
      else
        _x = past_emissions.mixed_for_description
        fail Say_expected_one_thing_had_another_thing__[ i_a, _x ]
      end
    end

    def fut_p

      exp_st = _future_stream

      -> * act_a, & act_p do

        if do_debug
          debug_IO.puts "(#{ act_a.inspect })"
        end

        if exp_st.unparsed_exists
          exp_a = exp_st.gets_one
          if exp_a
            Assert__[ act_p, act_a, exp_a.pop, exp_a ]  # yes eew
          else
            fail Say_expected_nothing_has_something__[ act_a ]
          end
        else
          # when no unparsed exists and above didn't trigger, ignore event
        end

        false  # if client depends on this, it shouldn't
      end
    end

    def future_is_now

      st = _future_stream
      if st.unparsed_exists
        a = st.gets_one
        if a
          a.pop
          fail Say_expect_something_had_nothing__[ a ]
        end
      end
    end

    def _future_stream
      @___future_stream ||= __build_future_stream
    end

    def __build_future_stream

      a = _future_expect_queue
      if a
        Home_::Polymorphic_Stream.via_array a
      else
        Home_::Polymorphic_Stream.the_empty_polymorphic_stream
      end
    end

    attr_reader :_future_expect_queue

    def future_black_and_white ev

      a = ev.express_into_under [], future_expression_agent_instance
      a.join '//'
    end

    alias_method :past_black_and_white, :future_black_and_white

    def future_expression_agent_instance
      Home_.lib_.brazen::API.expression_agent_instance
    end

    # ~ public models

    Event_Record = ::Struct.new :category, :event_proc

    class Emissions

      def initialize bx
        @_bx = bx
      end

      def only_on * i_a
        em_a = all_on_channel i_a
        case 1 <=> em_a.length
        when 0   ; em_a.fetch( 0 )
        when -1  ; fail __say_none( i_a )
        else     ; fail __say_many( em_a.length, i_a )
        end
      end

      def __say_none i_a
        _say "had none expected some", i_a
      end

      def __say_many d, i_a
        _say "expected one had #{ d }", i_a
      end

      def _say i_a
        " on #{ i_a.inspect }"
      end

      def all_on_channel i_a

        @_bx.fetch i_a do
          EMPTY_A_
        end
      end

      def mixed_for_description  # [ca]
        @_bx.a_
      end
    end

    # ~ support

    Assert__ = -> act_p, act_a, exp_p, exp_a do

      if exp_a == act_a
        if exp_p
          Assert_procs__[ act_p, act_a, exp_p ]
        end
      else
        fail Say_expected_one_thing_had_another_thing__[ exp_a, act_a ]
      end
    end

    Assert_procs__ = -> act_p, act_a, exp_p do

      if :expression == act_a[ 1 ]  # be :+[#br-023] aware
        exp_p[ Build_lines___[ & act_p ] ]
      else
        exp_p[ act_p[] ]
      end
    end

    Build_lines___ = -> & p do

      _expag = Home_.lib_.brazen::API.expression_agent_instance

      _expag.calculate [], & p

    end

    Say_expect_something_had_nothing__ = -> a do
      "expected #{ a.inspect }, had no more events"
    end

    Say_expected_nothing_has_something__ = -> a do
      "expected no more events, had #{ a.inspect }"
    end

    Say_expected_one_thing_had_another_thing__ = -> exp_a, act_a do
      "expected #{ exp_a.inspect } had #{ act_a.inspect }"
    end

    Say_expected_one_thing_had_many_things__ = -> exp_a, d do
      "expected 1 had #{ d } of #{ exp_a.inspect }"
    end

  end
end
