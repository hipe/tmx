module Skylab::Basic

  module Tree

    class Magnetics::Tree_via_Hash < Common_::Monadic

      def initialize x
        @upstream_x = x
      end

      def execute

        @node_class = Here_::Mutable
        _work @node_class.new, @upstream_x
      end

      def _work node, h

        slug = h.fetch :name
        node_ = @node_class.new slug
        node.add slug, node_

        a = h[ :children ]
        if a
          a.each do | h_ |
            _work node_, h_
          end
        end

        node_
      end
    end

    # ==
    # ==
  end
end
