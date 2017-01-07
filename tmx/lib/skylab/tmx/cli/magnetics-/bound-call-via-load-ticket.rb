module Skylab::TMX

  class CLI

    class Magnetics_::BoundCall_via_LoadTicket < Common_::Actor::Dyadic  # 1x

      # -

        def initialize lt, cli
          @CLI = cli
          @load_ticket = lt
        end

        def execute
          __init_sidesystem_module
          if __resolve_CLI_class
            __init_program_name_string_array
            __init_ARGV_for_sidesystem
            __flush
          end
        end

        def __flush

          _cli_class = remove_instance_variable :@__CLI_class
          _pn_s_a = remove_instance_variable :@__program_name_string_array
          _argv = remove_instance_variable :@__ARGV_for_sidesystem

          o = @CLI
          _cli = _cli_class.new _argv, o.sin, o.sout, o.stderr, _pn_s_a do
            o  # for special resources
          end
          _ = _cli.to_bound_call  # ..
          _  # #todo
        end

        def __init_ARGV_for_sidesystem

          _scn = @CLI.release_argument_scanner_for_sidesystem_mount__
          d, argv = _scn.close_and_release
          argv[ 0, d ] = EMPTY_A_
          @__ARGV_for_sidesystem = argv
          NIL
        end

        def __init_program_name_string_array

          _slug = @load_ticket.gem_name_elements.entry_string.gsub UNDERSCORE_, DASH_
          _pnsa = [ * @CLI.program_name_string_array, _slug ]
          @__program_name_string_array = _pnsa ; nil
        end

        def __resolve_CLI_class
          cls = @_sidesystem_module.const_get :CLI, false
          if cls
            @__CLI_class = cls ; ACHIEVED_
          else
            __when_no_CLI_class
          end
        end

        def __when_no_CLI_class
          ss_mod = @_sidesystem_module
          @CLI.listener.call :error, :expression, :not_mountable do |y|
            y << "no `CLI` class defiend for `#{ ss_mod.name }` - cannot mount."
          end
          UNABLE_
        end

        def __init_sidesystem_module
          @_sidesystem_module = @load_ticket.require_sidesystem_module
          NIL
        end
      # -
    end
  end
end
# #history: abstracted from main CLI file