module Skylab::Snag

  class Models::Manifest

    class Node_add__ < Agent_

      Snag_._lib.basic_fields :client, self,
        :absorber, :absrb_iambic_fully,
        :field_i_a, [ :is_dry_run, :verbose_x ]

      def initialize x_a
        @node, @client, @delegate = x_a.shift 3
        x_a.length.nonzero? and absrb_iambic_fully x_a
      end

      def execute
        int = determine_int
        int and work int
      end

    private

      def determine_int
        int, extern_h = greatest_node_integer_and_externals
        loop do
          int += 1
          (( x = extern_h[ int ] )) or break
          send_info_string "avoiding confusing number collision with #{ x }"
        end
        int
      end

      def greatest_node_integer_and_externals
        _scan = @client.all_nodes.reduce_by( & :is_valid )
        prefixed_h = {}
        greatest = _scan.each.reduce( -1 ) do |m, node|
          if node.identifier_prefix
            prefixed_h[ node.integer ] = node.render_identifier
            m
          else
            x = node.integer
            m > x ? m : x
          end
        end
        [ greatest, prefixed_h ]
      end

      def work d
        ok = Manifest_::Line_edit_[
          :at_position_x, 0,
          :new_line_a, @client.render_line_a( d, @node ),
          :is_dry_run, @is_dry_run,
          :verbose_x, @verbose_x,
          :client, @client,
          :delegate, @delegate ]
        ok and send_info_string "done."
        ok
      end
    end
  end
end
