module Skylab::TestSupport

  class CLI::Test_Support_Client___ < Home_.lib_.brazen::CLI

    expose_executables_with_prefix 'tmx-test-support-'

    def back_kernel
      Home_::API.krnl
    end

    def lookup_sidesystem_module

      # (because we have a nonstandard location)

      Home_
    end

    # ~ the currently cludgy way we get resources directly to the model action

    CLI_Client_ = self

    module Actions

      class Cover < CLI_Client_::Action_Adapter

        def prepare_for_employment_under x
          super
          @bound.sout = @resources.sout
          @bound.serr = @resources.serr
          @bound.invocation_string_array =
            @resources.invocation_string_array
          nil
        end

        def bound_call_from_parse_options
          # don't let the option parser swallow the '--' "early"
          nil
        end
      end
    end
  end
end
