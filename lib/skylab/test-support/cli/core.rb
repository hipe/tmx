module Skylab::TestSupport

  class CLI < TestSupport_.lib_.brazen::CLI

    # ~ we want this to go away eventually

    class << self

      def new * a
        new_top_invocation a, TestSupport_
      end
    end  # >>

    # ~ because there is perhaps no standard location

    def resolve_app_kernel
      @app_kernel = TestSupport_::API::Kernel.new @mod
      nil
    end

    # ~ experimental extension of action adapter base class, exactly :+[#br-023]

    class Action_Adapter < CLI::Action_Adapter

      def handle_event_selectively

        common_OES_p = super

        -> * i_a, & x_p do

          if :expression == i_a[ 1 ]

            expression_agent.calculate @resources.serr, & x_p

            RESULT_VALUE_FOR_TOP_CHANNEL___.fetch i_a.first
          else
            common_OES_p[ * i_a, & x_p ]
          end
        end
      end
    end

    RESULT_VALUE_FOR_TOP_CHANNEL___ = {
      info: nil,
      error: UNABLE_ }

    # ~ the currently cludgy way we get resources directly to the model action

    module Actions

      class Cover < Action_Adapter

        def receive_frame x
          super
          @bound.sout = @resources.sout
          @bound.serr = @resources.serr
          @bound.invocation_s_a = @resources.invocation_s_a
          nil
        end

        def parse_options
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

              def self.[] kernel, token

                TestSupport_.lib_.brazen::CLI::Client::Adapter::For::Face::Of::Hot::Maker.
                  new( TestSupport_ ).make_adapter( kernel, token )
              end
            end
          end
        end
      end
    end
  end
end
