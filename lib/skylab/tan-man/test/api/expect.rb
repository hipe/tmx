module Skylab::TanMan::TestSupport

  module API

    class Expect

      class << self

        def [] mod
          mod.include Test_Context_Methods__ ; nil
        end
      end

      module Test_Context_Methods__

        def call_API * x_a
          @result = subject.call( * x_a ) do |invocation|
            invocation.set_event_receiver event_receiver
          end
        end

        def event_receiver
          @event_receiver ||= bld_event_receiver
        end

        def bld_event_receiver
          Event_Receiver__.new ( do_debug && some_debug_stream )
        end
      end

      class Event_Receiver__

        def initialize dbg_IO
          if dbg_IO
            @do_debug = true
            @debug_IO = dbg_IO
          else
            @do_debug = false
          end
          @ev_a = []
        end

        def receive_event ev
          @do_debug and express_event ev
          @ev_a.push ev
          if ev.has_tag :ok
            ev.ok ? true : false
          end
        end

        def gets
          @ev_a.shift
        end

        def executable_wrapper_class
          TanMan_::API::Bound_Call_
        end

        def app_name
          "(tm)"
        end

      private

        def express_event ev
          @ev = ev ; @ok_s = ok_s ; @tci = ev.terminal_channel_i
          @mems = "(#{ ev.members * ', ' })"
          y = ::Enumerator::Yielder.new do |s|
            @debug_IO.puts "#{ @ok_s } #{ @tci } #{ @mems } - #{ s.inspect }"
          end
          ev.render_all_lines_into_under y, TanMan_::API::EXPRESSION_AGENT__
          nil
        end

        def ok_s
          if @ev.has_tag :ok
            @ev.ok ? '(ok)' : '(not ok)'
          else
            '(ok? not ok?)'
          end
        end
      end

      module Test_Context_Methods__

        def expect * x_a, & p
          Expect.new( x_a, p , self ) ; nil
        end

        def expect_failed
          expect_no_more_events
          @result.should eql false
        end

        def expect_no_more_events
          ev = event_receiver.gets
          if ev
            @context.send :fail, "expected no more events, had #{ ev.terminal_channel_i }"
          end ; nil
        end
      end

      Expect__ = self

      class Expect__

        def initialize *a
          @x_a, @p, @context = a
          @d = -1 ; @last_d = @x_a.length - 1
          expect_one_event
          @ok && expect_channel
          @ok && process_terminal_channel_i
          @ok && process_message_bodies
        end

        def expect_one_event
          @ev = @context.event_receiver.gets
          if @ev
            @ok = true
          else
            @context.send :fail, "expected more events, had none."
            @ok = false
          end ; nil
        end

        def expect_channel
          send :"expect_OK_value_for_#{ gets_one }"
        end

        def expect_OK_value_for_failed
          if @ev.has_tag :ok
            if @ev.ok
              @context.send :fail, "was 'ok', expected not"
              @ok = false
            end
          else
            when_no_tag
          end
        end

        def expect_OK_value_for_succeeded
          if @ev.has_tag :ok
            if ! @ev.ok
              @context.send :fail, "was not 'ok', exppected 'ok'"
              @ok = false
            end
          else
           when_no_tag
          end
        end

        def when_no_tag
          @context.send :fail, "did not have 'ok' tag"
          @ok = false ; nil
        end

        def expect_OK_value_for_neutral
          if @ev.has_tag :ok
            @context.send :fail, "expected event not to have 'ok' tag"
            @ok = false
          end
        end

        def process_terminal_channel_i
          if unparsed_exists
            exp = gets_one
            act = @ev.terminal_channel_i
            if exp != act
              @context.instance_exec do
                exp.should eql act
              end
              @ok = false
            end
          else
            @ok = false
          end ; nil
        end

        def process_message_bodies
          if unparsed_exists
            _exp = TanMan_::API::EXPRESSION_AGENT__
            y = ::Enumerator::Yielder.new do |act|
              if unparsed_exists
                exp = gets_one
                if exp != act
                  @context.instance_exec do
                    act.should eql exp
                  end
                  @ok = false
                end
              else
                @context.send :fail, "unexpected extra line from #{
                  }rendering: #{ act.inspect }"
                @ok = false
              end
            end
            @ev.render_all_lines_into_under y, _exp
          else
            @ok = false
          end
        end

        def unparsed_exists
          @ok = @d != @last_d
        end

        def gets_one
          @x_a.fetch( @d += 1 )
        end
      end
    end
  end
end
