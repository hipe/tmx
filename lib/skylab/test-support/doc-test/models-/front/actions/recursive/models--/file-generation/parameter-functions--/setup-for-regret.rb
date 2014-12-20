module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Recursive

        class Models__::File_Generation

          class Parameter_Functions__::Setup_for_Regret < Parameter_Function_

            # ~ yes / no validation ( abstraction candidate )

            def normalize
              if @value_x
                via_value_resolve_do
              else
                @do = true
                ACHIEVED_
              end
            end

          private

            def via_value_resolve_do
              case @value_x
              when YES__
                @do = true
                ACHIEVED_
              when NO__
                @do = false
                ACHIEVED_
              else
                when_unrecognized_argument
              end
            end

            NO__ = 'no'.freeze
            YES__ = 'yes'.freeze

            def when_unrecognized_argument  # #todo:cover-me
              maybe_send_event :error, :unrecognzied_parameter_argument do
                build_unrecognized_param_arg [ YES__, NO__ ]
              end
              UNABLE_
            end

            def flush
              yes = @do
              @generation.during_generate do | generate |
                generate.during_output_adapter do | oa |
                  oa.receive_do_regret_setup yes
                end
              end
              ACHIEVED_
            end
          end
        end
      end
    end
  end
end
