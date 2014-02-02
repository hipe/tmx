module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Fixture_Client

      class Plugins__::Rainbow_Kick  # read [#021] what is a rainbow kick

        include Socket_Agent_Constants_

        def initialize host
          @auto_shutdown_seconds_f = 3.0  # any short amt is probably fine
          @host = host ; @is_enabled = RAINBOW_KICK_IS_ENABLED_BY_DEFAULT__
          @logfile_path = "#{ DEFAULT_LOG_DIR__ }/#{ DEFAULT_LOG_FILE__ }"
          @poll_timeout_seconds_f = 5.0  # #storypoint-15
          @y = host.get_qualified_stderr_line_yielder
        end

        def on_build_option_parser op

          op.on '--logfile <path>', "(default: #{ @logfile_path })" do |x|
            @logfile_path = x
          end

          if @is_enabled
            op.on '--no-rainbow-kick', "rainbow kick is enabled by default. #{
                }this option disables it." do
              @is_enabled = false
            end
          else
            op.on '--enable', "enable rainbow kick." do
              @is_enabled = true
            end
          end
        end

        def on_attempt_to_connect
          if @is_enabled
            RAINBOW_KICK_IS_ENABLED_BY_DEFAULT__ and
              @y << "(enabled by default)"
            flip_result prepare_to_connect || resolve_connection
          else
            @y << "(not enabled)"
            PROCEDE_
          end
        end

      private
        def flip_result ec
          if ec
            @y << "(failed to connect (result: #{ ec })"
            false
          else
            @y << "fork parent is optimistic about success of child"
            @poll_timeout_seconds_f
          end
        end

        def prepare_to_connect
          init_spawn_argv
          resolve_spawn_options
        end

        def init_spawn_argv
          y = [ Plugins__::Rainbow_Kick::Script_.dir_pathname.
            join( 'rainbow-kick-server' ).to_path ]
          y.push '--seconds-of-inactivity-for-auto-shutdown',
            @auto_shutdown_seconds_f.to_s
          y.push '--reason', 'rainbow kick'
          @spawn_argv = y
          SILENT_
        end

        def resolve_spawn_options
          ec = prepare_spawn_options
          ec || write_spawn_options
        end

        def prepare_spawn_options
          resolve_logfile_path
        end

        def resolve_logfile_path
          dn = ::File.dirname @logfile_path
          if ! ::File.directory? dn
            @y << "fatal: logfile directory must exist: #{ dn }"
            GENERAL_ERROR_
          end
        end

        def write_spawn_options
          h = {}
          twice = [ @logfile_path, 'a+' ]
          h[ :out ] = twice  # (doing this the shorter way ([:out, :err] =>..])
          h[ :err ] = twice  # would work in spawn but not in open3)
          # h[ :unsetenv_others ] = true  # assume your environment is set
          @spawn_options = h
          PROCEDE_
        end

        def resolve_connection
          pid = spawn( * @spawn_argv, @spawn_options )
          ::Process.wait pid
          status = $?
          process_child_process_exitstatus status.exitstatus
        end

        def process_child_process_exitstatus d
          if d.zero?
            PROCEDE__
          else
            @y << "failed: fork parent had nonzero exitstatus: #{ d }"
            d
          end
        end

        DEFAULT_LOG_FILE__ = 'rainbow.log'.freeze
        DEFAULT_LOG_DIR__ = './logs'.freeze

        FAILED__ = 4 ; PROCEDE__ = nil

        RAINBOW_KICK_IS_ENABLED_BY_DEFAULT__ = true
      end
    end
  end
end
