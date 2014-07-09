module Skylab::Snag

  class Library_::Manifest

    class Changer_ < Funcy_

      Snag_::Lib_::Basic_Fields[ :client, self,
        :passive, :absorber, :absrb_iambic_passively,
        :field_i_a, [ :callbacks ] ]

      def initialize x_a
        @node = x_a.shift
        absrb_iambic_passively x_a
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
