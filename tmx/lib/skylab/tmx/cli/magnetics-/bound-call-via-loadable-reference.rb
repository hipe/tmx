module Skylab::TMX

  class CLI

    class Magnetics_::BoundCall_via_LoadableReference < SimpleModel_  # 2x here

      class << self
        def call lt, cli
          define do |o|
            o.CLI = cli
            o.loadable_reference = lt
          end.execute
        end
        alias_method :[], :call
      end  # >>

      # -

        def initialize
          @is_for_help = false
          yield self
          # don't freeze because memoizes for waypoints
        end

        attr_writer(
          :CLI,
          :is_for_help,
          :loadable_reference,
        )

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
          _cli = _cli_class.new _argv, o.stdin, o.stdout, o.stderr, _pn_s_a do
            o  # for special resources
          end
          _ = _cli.to_bound_call  # ..
          _  # #todo
        end

        def __init_ARGV_for_sidesystem

          ts = @CLI.release_argument_scanner_for_mounted_operator.token_scanner

          if @is_for_help
            d, argv = ts.LIQUIDATE_TOKEN_SCANNER  # implicit assertion
            # YUCK accomodate the 2 forms of help request, use original token. see #hereA in cli.rb
            2 <= argv.length || fail
            if HELP_RX =~ argv[0]
              argv[ 1, 1 ] = EMPTY_A_

            elsif HELP_RX =~ argv[1]
              argv[ 0, 1 ] = EMPTY_A_

            else
              self._SANITY
            end
          elsif ts.no_unparsed_exists
            argv = EMPTY_A_  # there is danger here
          else
            d, argv = ts.LIQUIDATE_TOKEN_SCANNER  # implicit assertion
            argv[ 0, d ] = EMPTY_A_
              # (typically, removes head span of ARGV holding sidesystem name)
          end

          @__ARGV_for_sidesystem = argv
          NIL
        end

        def __init_program_name_string_array

          _slug = @loadable_reference.gem_name_elements.entry_string.gsub UNDERSCORE_, DASH_
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
          @_sidesystem_module = @loadable_reference.require_sidesystem_module
          NIL
        end
      # -

      # ==
      # ==
    end
  end
end
# #history: abstracted from main CLI file
