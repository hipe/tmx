module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Generate

        Parameter_Functions_::Chomp_module = -> gen, & oes_p do

          gen.during_output_adapter do | oa |

            s = oa.get_test_module_name

            s.gsub! %r(::[^:]+\z), EMPTY_S_

            oa.set_test_module_name s

          end
        end

      end
    end
  end
end
