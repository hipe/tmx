module Skylab::Basic

  module Tree

    Magnetics::Tree_via_Paths = -> upstream_x do

        root = Here_::Mutable.new

        upstream_x.each do |path|

          root.touch_node path
        end

        root
    end

    # ==
    # ==
  end
end
