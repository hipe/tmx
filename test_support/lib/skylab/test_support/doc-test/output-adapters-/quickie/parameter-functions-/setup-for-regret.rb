module Skylab::TestSupport

  module DocTest

    class Output_Adapters_::Quickie

          class Parameter_Functions_::Setup_for_Regret < Parameter_Function_

            description do | y |

              y << "include the extra code for this being a standalone node"

            end

            def normalize
              ACHIEVED_
            end

            def flush
              @generation.during_generate do | o |
                o.receive_do_setup_for_regret true
              end
            end
          end


    end
  end
end
