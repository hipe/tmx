module Skylab::GitViz

  class Test_Lib_::Mock_System::Fixture_Server

    class Plugins__::Auto_Shutdown  # read [#022] shutdown timer narrative

      Test_Lib_::Mock_System::Socket_Agent_[ self ]
      include Test_Lib_::Mock_System::Socket_Agent_Constants_

      def initialize host
        @do_engage = false ; @do_ignore_one = true ; @do_test = false
        @host = host ; @port_d = host.port_d
        @serr_p = host.stderr_reference
        @stderr = host.get_qualified_serr
        @timer_thread = @seconds_s = nil
        @verbosity_level_d = INFO_LEVEL__
        @y = host.get_qualified_stderr_line_yielder
        @yy = host.stderr_line_yielder
      end

      def on_build_option_parser op
        op.on '--seconds-of-inactivity <positive-int>', "when specified, #{
          }if this many seconds have elapsed since the", "last query the #{
           }server will automatically shut itself", "down (which may be #{
            }useful for a #rainbow-kick)." do |x|
          @seconds_s = x
        end
        op.on '--test-mode', "stay in server, don't go to responder #{
            }(for development)" do
          @y << "test mode activated. #{
            }requests will not go to business responder."
          @do_test = true
        end
        op.on '--less-verbose', 'reduces verbosity by one level.' do
          if @verbosity_level_d.zero?
            @y << "(verbosity level is already at the lowest level)"
          else
            @verbosity_level_d -= 1
          end
        end
        op.on '--more-verbose', 'increase verbosity by one level.' do
          if DEBUG_LEVEL__ == @verbosity_level_d
            @y << "(verbosity level is already the highest level)"
          else
            @verbosity_level_d += 1
          end
        end
      end

      INFO_LEVEL__ = 1
      DEBUG_LEVEL__ = INFO_LEVEL__ + 1

      def on_options_parsed
        init_verbosity_ivars
        @seconds_s and parse_seconds
      end
    private

      def init_verbosity_ivars
        [ :'@do_info', :'@do_debug' ].each_with_index do |ivar, d|
          instance_variable_set ivar, ( d < @verbosity_level_d )
        end
      end

      def parse_seconds
        if /\A\d+(?:\.\d+)?\z/ =~ @seconds_s
          init_verbosity_ivars
          @do_engage = true
          @sec_f = @seconds_s.to_f
          PROCEDE_
        else
          @yy << "fatal: need positive integer for seconds, had #{
            }#{ @seconds_s.inspect }"
          EARLY_EXIT_
        end
      end

    public
      def on_received_request_strings
        if @do_engage
          if @is_hot
            reset_timer_to_now_because :request_received
          elsif @do_ignore_one and 'shut it down' == @host.bfr_a.fetch( 0 )
            @do_ignore_one = false # yep, ignore our own (presumably) request
          else
            @y << "ignoring request received b.c shutdown request already sent!"
          end
        end ; SILENT_
      end

    public
      def on_front_responder_initted responder
        if @do_engage
          responder.on_response_started( & method( :response_started_notify ) )
        end
        PROCEDE_  # #storypoint-45
      end
    private
      def response_started_notify _response
        if @do_engage
          if @is_hot
            reset_timer_to_now_because :on_response_started
          else
            @y << "ignoring response started b.c shutdown request already sent!"
          end
        end ; SILENT_
      end

      def reset_timer_to_now_because reason_i
        old_now = @time_of_last_activity
        @time_of_last_activity = ::Time.now
        if @do_info
          report_the_difference reason_i, ( @time_of_last_activity - old_now )
        end
        restart_timer
      end

      def report_the_difference reason_i, delta
        @y << "countdown re-started because #{ reason_i.to_s.gsub '_', ' ' } #{
          }(had #{ say_time @sec_f - delta } left on clock)"
      end

    public
      def on_start
        if @do_test
          @context, @socket = @host.context_and_socket
        end
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
        @do_info and @y << "countdown timer started with #{ say_time } left.."
        start_new_timer_thread
      end

      def restart_timer
        terminate_current_timer_thread
        start_new_timer_thread
      end

      def start_new_timer_thread
        @timer_thread = ::Thread.new do
          sleep @sec_f
          ex = nil
          begin
            timer_has_fired
          rescue ::StandardError => ex
          end
          if ex
            when_timer_thread_throws_an_exception ex
          else
            @do_info and @y << "(got to end of timer thread yay)"
          end ; nil
        end
        @do_debug and @y << "started thread (#{ @timer_thread })"
        PROCEDE_
      end

      def when_timer_thread_throws_an_exception ex
        @serr_p[].puts
        @y << "(timer thread aborted due to exception: #{ ex.message })" ; nil
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
        @do_info and report_live_another_day f
      end

      def report_live_another_day f
        @y << "it's been #{ say_time f } seconds since last activity. #{
          }you may live another day."
      end

      def threshold_reached f   # #storypoint-130 is relevant here too
        @stderr.write "triggered: omg it's been #{ say_time } of inactivity #{
          }so .."
        @is_hot = false
        y = ::Enumerator::Yielder.new do |msg|
          @y << "(from thread:) #{ msg }"
        end
        _reason_s = "because of #{ say_time } of inactivity"
        _shutdown = Shutdown_Request__.new y, @port_d, _reason_s
        _shutdown.send_request_to_shut_it_down
        @serr_p[].puts " sent shutdown message."
        SILENT_
        # the current thread is the timer thread! so we don't terminate it
      end

    public
      def on_request buffer_a
        @do_test and swallow_request buffer_a
      end
    private
      def swallow_request buffer_a
        send_a = [ 'result_code', '73', 'statement', '2', 'info',
          "server is in test mode, ignoring: #{ buffer_a * ' ' }" ]
        buffer_a.clear
        send_strings send_a
        SILENT_
      end

    public
      def on_shutdown  # #storypoint-130
        if ! @do_engage
          @do_info and @y << "(was never active. nothing to do)"
        elsif @timer_thread
          @stderr.write "joining current timer thread .."  # #todo:now
          @timer_thread.join
          @yy << " done."
        else
          @y << "(has no timer thread to terminate)"
        end
        PROCEDE_
      end
    private
      def terminate_current_timer_thread
        @do_debug and @stderr.write "(terminating current thread .."
        x = @timer_thread.terminate
        @do_debug and @serr_p[].puts " (#{ x }) done.)"
        @timer_thread = nil
      end

      def emit_error_string s  # #hook-out
        @y << "cannot shutdown: #{ s }"
      end

      def say_time f=nil
        f ||= @sec_f
        1.0 == f or s = 's'
        "#{ FMT__ % f } second#{ s }"
      end ; FMT__ = '%.2f'.freeze

      class Shutdown_Request__ < Shutdown_Message_

        Test_Lib_::Mock_System::Socket_Agent_[ self ]
        include Test_Lib_::Mock_System::Socket_Agent_Constants_

        def initialize y, port_d, reason_s
          @port_d = port_d ; @y = y
          super reason_s
        end
        def send_request_to_shut_it_down
          cnct || send
        end
      private
        def cnct
          resolve_context_and_bind_request_socket do |sock|
            sock.setsockopt ::ZMQ::LINGER, 1_000  # dunno
          end
        end
        def send
          send_strings @message_s_a
          close_socket_and_terminate_context
          SILENT_
        end
        def emit_error_string s
          @y << s ; nil
        end
      end
    end
  end
end
