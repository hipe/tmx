module Skylab::GitViz

  class Test_Lib_::Mock_System::Fixture_Server

    class Plugins__::Auto_Shutdown  # read [#022] shutdown timer narrative

      Test_Lib_::Mock_System::Socket_Agent_[ self ]
      include Test_Lib_::Mock_System::Socket_Agent_Constants_

      def initialize client
        @client = client ; @do_engage = false
        @port_d = client.port_d
        @serr = client.stderr
        @stderr = client.get_qualified_serr
        @timer_thread = @seconds_s = nil
        @y = client.get_qualified_stderr_line_yielder
        @yy = client.stderr_line_yielder
      end

      def on_build_option_parser op
        op.on '--seconds-of-inactivity <positive-int>', "when specified, #{
          }if this many seconds have elapsed since the", "last query the #{
           }server will automatically shut itself", "down (which may be #{
            }useful for a #rainbow-kick)." do |x|
          @seconds_s = x
        end
      end

      def on_options_parsed
        @seconds_s and parse_seconds
      end
    private
      def parse_seconds
        if /\A\d+\z/ =~ @seconds_s
          @do_engage = true
          @sec_d = @seconds_s.to_i
          @sec_f = @sec_d.to_f
          PROCEDE_
        else
          @yy << "fatal: need positive integer for seconds, had #{
            }#{ @seconds_s.inspect }"
          EARLY_EXIT_
        end
      end

    public
      def on_responder_initted responder
        if @do_engage
          responder.on_response_started( & method( :response_started_notify ) )
        end
        PROCEDE_  # #storypoint-45
      end

    private
      def response_started_notify _response
        if @is_hot
          now = ::Time.now
          delta = now - @time_of_last_activity
          @time_of_last_activity = now
          @y << "countdown re-started (had #{ FMT__ % ( @sec_f - delta ) } #{
            }seconds left on clock..)"
          restart_timer
        else
          @y << "ignoring response, request for shutdown already sent!"
        end ; nil
      end

    public
      def on_start
        @do_engage ? attempt_to_start : PROCEDE_
      end
    private
      def attempt_to_start
        @is_hot = true
        ec = a_ruby_engine_other_than_MRI_is_required
        ec || start_timer
      end

      def a_ruby_engine_other_than_MRI_is_required  # [#022]:#then-there-was-MRI
        /\Aruby\b/ =~ ::RUBY_ENGINE and but_you_are_running_MRI
      end
      def but_you_are_running_MRI
        @y << "plugin cannot run under MRI. it needs true concurrency."
        @y << "says: if you start the server from the front it is supposed #{
          }to switch to rbx automatically."
        EARLY_EXIT_
      end

      def start_timer
        @time_of_last_activity = ::Time.now
        @y << "countdown timer started with #{ @sec_d } seconds left.."
        start_new_timer_thread
      end

      def restart_timer
        terminate_current_timer_thread
        start_new_timer_thread
      end

      def start_new_timer_thread
        @timer_thread = ::Thread.new do
          sleep @sec_d
          timer_has_fired
          @y << "(got to end of thread)"
        end
        @y << "started thread (#{ @timer_thread })"
        PROCEDE_
      end

      def timer_has_fired
        _now = ::Time.now
        elapsed_seconds_f = _now - @time_of_last_activity
        case elapsed_seconds_f <=> @sec_f
        when -1, 0 ; threshold_not_reached elapsed_seconds_f
        when     1 ; threshold_reached elapsed_seconds_f
        end ; nil
      end

      def threshold_not_reached f  # #storypoint-110 chatty logging
        @y << "it's been #{ FMT__ % f } seconds since last activity. #{
          }you may live another day."
      end

      def threshold_reached f   # #storypoint-130 is relevant here too
        @y << "triggered: omg it's been #{ FMT__ % f } seconds of #{
          }inactivity so:"
        @is_hot = false
        # the current thread is the timer thread! so we don't terminate it
        init_context ; init_socket
        @socket.setsockopt ::ZMQ::LINGER, 1_000  # dunno
        ec = connect_socket
        ec || send_message_talking_about_shut_it_down
      end

      def send_message_talking_about_shut_it_down
        ec = send_strings [ 'shut it down' ]
        ec or close_socket_and_terminate_context
      end

      FMT__ = '%.2f'.freeze

    public
      def on_shutdown  # #storypoint-130
        if ! @do_engage
          @y << "(was never active. nothing to do)"
        elsif @timer_thread
          @stderr.write "joining current timer thread .."
          @timer_thread.join
          @yy << " done."
        else
          @y << "(has no timer thread to terminate)"
        end
        PROCEDE_
      end
    private
      def terminate_current_timer_thread
        @stderr.write "(terminating current thread .."
        x = @timer_thread.terminate
        @serr.puts " (#{ x }) done.)"
        @timer_thread = nil
      end

      def emit_error_string s  # #hook-out
        @y << "cannot shutdown: #{ s }"
      end
    end
  end
end
