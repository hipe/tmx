module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Recursive

        class Models__::File_Generation

          class Parameter_Functions__::Regret_setup < Parameter_Function_

            # ~ yes / no validation ( abstraction candidate )

            def normalize
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

            # ~

            def flush
              @generation.set_template_variable :do_regret_setup, @do
              ACHIEVED_
            end
          end
        end
      end
    end
  end
end
