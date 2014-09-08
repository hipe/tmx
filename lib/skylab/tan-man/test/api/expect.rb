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
          Event_Receiver__.new ( do_debug && some_debug_IO )
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

        def receive_negative_event ev
          ev.ok and self._WHERE
          receive_event ev
        end

        def receive_event ev
          @do_debug and express_event ev
          ev_ = ev.to_event
          if ev_.has_tag :flyweighted_h
            ev.object_id == ev_.object_id or self._DO_ME
            _h = ev_.flyweighted_h.dup
            ev_ = ev_.dup_with :flyweighted_h, ev_.flyweighted_h.dup
            ev = ev_
          end
          @ev_a.push ev
          if ev_.has_tag :ok
            ev_.ok ? true : false
          end
        end

        def gets
          @ev_a.shift
        end

        def app_name
          "(tm)"
        end

      private

        def express_event ev
          @ev = ev ; @ev_ = ev.to_event
          @ok_s = ok_s ; @tci = ev.terminal_channel_i
          @mems = "(#{ @ev_.tag_names * ', ' })"
          y = ::Enumerator::Yielder.new do |s|
            @debug_IO.puts "#{ @ok_s } #{ @tci } #{ @mems } - #{ s.inspect }"
          end
          ev.render_all_lines_into_under y, TanMan_::API::EXPRESSION_AGENT__
          nil
        end

        def ok_s
          ev_ = @ev.to_event
          if ev_.has_tag :ok
            ev_.ok ? '(ok)' : '(not ok)'
          else
            '(ok? not ok?)'
          end
        end
      end

      module Test_Context_Methods__

        def expect * x_a, & p
          Expect.new( x_a, p , self ).result
        end

        def expect_failed
          expect_no_more_events
          @result.should eql false
        end

        def expect_succeded
          expect_no_more_events
          @result.should eql true
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
          @will_pass = true
          expect_one_event
          @stay && expect_channel
          @stay && process_terminal_channel_i
          @stay && process_message_bodies
          if @will_pass && @p
            process_proc
          end ; nil
        end

        attr_reader :result

        def expect_one_event
          @ev = @context.event_receiver.gets
          if @ev
            @ev_ = @ev.to_event
            @stay = true
          else
            @ev_ = nil
            send_failure "expected more events, had none."
          end ; nil
        end

        def expect_channel
          send :"expect_OK_value_for_#{ gets_one }"
        end

        def expect_OK_value_for_failed
          if @ev_.has_tag :ok
            if @ev_.ok
              send_failure "was 'ok', expected not"
            end
          else
            when_no_tag
          end
        end

        def expect_OK_value_for_succeeded
          if @ev_.has_tag :ok
            if ! @ev_.ok
              send_failure "was not 'ok', expected 'ok'"
            end
          else
            when_no_tag
          end
        end

        def when_no_tag
          send_failure "did not have 'ok' tag"
        end

        def expect_OK_value_for_neutral
          if @ev.has_tag :ok
            send_failure "expected event not to have 'ok' tag"
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
              @stay = false
            end
          else
            @stay = false
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
                  @stay = false
                end
              else
                send_failure "unexpected extra line from #{
                  }rendering: #{ act.inspect }"
              end
            end
            @ev.render_all_lines_into_under y, _exp
          else
            @stay = false
          end
        end

        def process_proc
          @result = @p[ @ev ] ; nil
        end

        def unparsed_exists
          @stay = @d != @last_d
        end

        def gets_one
          @x_a.fetch( @d += 1 )
        end

        def send_failure msg
          @result = @stay = @will_pass = false
          @context.send :fail, msg ; nil
        end
      end
    end
  end
end
