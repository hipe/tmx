module Skylab::TestSupport

  class CLI < TestSupport_.lib_.brazen::CLI

    # ~ we want this to go away eventually

    class << self

      def new * a
        new_top_invocation a, TestSupport_::API.krnl
      end
    end  # >>

    # ~ the currently cludgy way we get resources directly to the model action

    module Actions

      class Cover < CLI::Action_Adapter

        def receive_frame x
          super
          @bound.sout = @resources.sout
          @bound.serr = @resources.serr
          @bound.invocation_s_a = @resources.invocation_s_a
          nil
        end

        def bound_call_from_parse_options
          # don't let the option parser swallow the '--' "early"
          nil
        end
      end
    end

    # ~ for tmx integration

    Client = self

    module Adapter  # #hook-out for [tmx] integration
      module For
        module Face
          module Of
            module Hot

              def self.[] kr, tok

                TestSupport_.lib_.brazen::CLI::Client.fml TestSupport_, kr, tok
              end
            end
          end
        end
      end
    end
  end
end
