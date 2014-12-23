module Skylab::TestSupport

  module DocTest

    class Output_Adapters_::Quickie

      Parameter_Functions_::Subject_proc = -> gen, & oes_p do

        gen.during_generate do | oa |

          oa.in_pre_describe do | y |

            y << "Subject_ = -> * x_a, & p do"

            y << "  if x_a.length.nonzero? || p"

            y << "    #{ oa.acon }_#{ oa.bmod }#{ oa.cmod }[ * x_a, & p ]"

            y << "  else"

            y << "    #{ oa.acon }_#{ oa.bmod }#{ oa.cmod }"

            y << "  end"

            y << "end"

            nil
          end
        end
      end
    end
  end
end
