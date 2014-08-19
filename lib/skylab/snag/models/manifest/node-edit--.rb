module Skylab::Snag

  class Models::Manifest

    class Node_edit__ < Agent_

      Snag_::Lib_::Basic_Fields[ :client, self,
        :absorber, :absrb_iambic_fully,
        :field_i_a, [ :is_dry_run, :verbose_x ] ]

      def initialize x_a
        @node, @client, @listener = x_a.shift 3
        x_a.length.nonzero? and absrb_iambic_fully x_a
      end

      def execute
        Manifest_::Line_edit_[
          :at_position_x, @node.identifier.render,
          :new_line_a, @client.render_line_a( nil, @node ),
          :is_dry_run, @is_dry_run,
          :verbose_x, @verbose_x,
          :client, @client,
          :listener, @listener ]
      end
    end
  end
end
