module Skylab::Snag

  class Services::Manifest

    class Changer_ < Funcy_

      MetaHell::FUN::Fields_[ :client, self, :scan_method, :parse,
                              :field_i_a, [ :callbacks ] ]
      def initialize( node, * x_a )
        @node = node
        parse x_a
        @rest_a = x_a
      end

      def execute
        Manifest::Line_editor_[
          :at_position_x, @node.identifier.render,
          :new_line_a, @callbacks.render_line_a( @node ),
          * @callbacks.get_subset_a, * @rest_a ]
      end
    end
  end
end
