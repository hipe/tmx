module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Recursive

        class Models__::File_Generation

          Parameter_Functions__::Chomp_module = -> gen, val_x, & oes_p do

            gen.during_generate do | generate |

              s = generate.get_business_test_module_name

              s.gsub! %r(::[^:]+\z), EMPTY_S_

              generate.set_business_test_module_name s

            end
          end
        end
      end
    end
  end
end
