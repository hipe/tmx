module Skylab::Snag

  class Models::Manifest

    class Node_edit__ < Agent_

      Snag_::Lib_::Basic_Fields[ :client, self,
        :passive, :absorber, :absrb_iambic_passively,
        :field_i_a, [ :client ] ]

      def initialize x_a
        @node = x_a.shift
        absrb_iambic_passively x_a
        @rest_a = x_a
      end

      def execute
        Manifest_::Line_edit_[
          :at_position_x, @node.identifier.render,
          :new_line_a, @client.render_line_a( @node ),
          * @client.get_subset_a, * @rest_a ]
      end
    end
  end
end
