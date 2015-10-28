module Skylab::Callback::TestSupport

  module Future_Expect

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
      ( @_future_expect_queue ||= [] ).push a
      NIL_
    end

    def future_expect_no_more
      ( @_future_expect_queue ||= [] ).push false
      NIL_
    end

    def fut_p

      st = _future_stream

      -> * i_a, & oes_p do

        if do_debug
          debug_IO.puts "(#{ i_a.inspect })"
        end

        if st.unparsed_exists
          a = st.gets_one
          if a
            p = a.pop
            if a == i_a
              if p
                if :expression == i_a[ 1 ]  # be :+[#br-023] aware
                  p[ Build_lines___[ & oes_p ] ]
                else
                  p[ oes_p[] ]
                end
              end
            else
              fail "expected #{ a.inspect } had #{ i_a.inspect }"
            end
          else
            fail "expected no more events, had #{ i_a.inspect }"
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
          fail "expected #{ a.inspect }, had no more events"
        end
      end
    end

    def _future_stream
      @___future_stream ||= __build_future_stream
    end

    def __build_future_stream

      a = @_future_expect_queue  # we want warnings
      if a
        Home_::Polymorphic_Stream.via_array a
      else
        Home_::Polymorphic_Stream.the_empty_polymorphic_stream
      end
    end

    def future_black_and_white ev

      future_expression_agent_instance = Home_.lib_.brazen::API.expression_agent_instance
      a = ev.express_into_under [], future_expression_agent_instance
      a.join '//'
    end

    Build_lines___ = -> & p do

      _expag = Home_.lib_.brazen::API.expression_agent_instance

      _expag.calculate [], & p

    end

    Cheap_Event_Record___ = ::Struct.new :category, :event_proc

  end
end
