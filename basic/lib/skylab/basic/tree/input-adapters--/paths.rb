module Skylab::Basic

  module Tree

    # ->

      Input_Adapters__::Paths = -> upstream_x do

        root = Tree_::Mutable_.new

        upstream_x.each do | path |

          root.touch_node path
        end

        root
      end

      # <-
  end
end
