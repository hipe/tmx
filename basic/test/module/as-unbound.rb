module Skylab::Basic::TestSupport

  module Module::As_Unbound

    def self.[] tcc
      tcc.include self
    end

    define_singleton_method :_dangerous_memoize, TestSupport_::DANGEROUS_MEMOIZE

    _dangerous_memoize :kernel_one_ do

      module MaMS_K1

        module Models_

          module Node_One_which_is_Module

            module Actions

              Node_5_func = -> arg1, bnd, & p do
                p.call :hi_from_5
                "(5 says: pong: #{ arg1 })"
              end
            end
          end

          class Node_Two_which_is_Class
            module Actions
              module Node_6_Mod
                module Actions
                  Node_7_func = -> arg1, bnd, & p do
                    p.call :hi_from_7
                    "(7 says: pong: #{ arg1 })"
                  end
                end
              end
            end
          end

          class Node_Three_which_is_No_See
            Actions = nil
          end

          Node_Four_which_is_Function = -> arg1, bnd, & p do

            p.call :info, :expression, :wazoozie do | y |

              y << "#{ highlight 'yay' } wahoo: #{ arg1 }"
            end

            "(4 says: pong: #{ arg1 })"
          end
        end
      end

      Home_.lib_.brazen::Kernel.new MaMS_K1
    end
  end
end
