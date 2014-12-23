module Skylab::TestSupport

  module DocTest

    class Output_Adapters_::Quickie

      module Parameter_Functions_
        Callback_::Autoloader[ self, :boxxy ]  # for now
      end


      Parameter_Functions_::Eponymous_const = -> gen, & oes_p do

        # this parameter function puts limits on your whole spec file:
        # it takes up a root-level "before" block which (in quickie)
        # means you cannot use other before blocks at a deeper level.
        # as always, becuase it writes to a const, know your namespace.

        gen.during_generate do | oa |

          oa.in_pre_body do | y |

            y << "before :all do"

            _stem = oa.chomp_trailing_underscores oa.business_module_basename

            y << "  #{ _stem }#{ UNDERSCORE_ } #{
              }= #{ oa.test_local_qualified_business_module_name }"

            y << "end"

            nil
          end
        end
      end
    end
  end
end
