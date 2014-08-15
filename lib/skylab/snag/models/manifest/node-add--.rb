module Skylab::Snag

  class Models::Manifest

    class Node_add__ < Agent_

      Snag_::Lib_::Basic_Fields[ :client, self,
        :passive, :absorber, :absrb_iambic_passively,
        :field_i_a, [ :client ] ]

      def initialize x_a
        @node = x_a.shift
        absrb_iambic_passively x_a
        @info_event_p = Detect_info_p[ x_a ]
        @rest_a = x_a
      end

      Detect_info_p = Snag_::Lib_::Basic_Fields[].iambic_detect.curry[ :info_event_p ]

      def execute
        begin
          r = int = determine_int or break
          @int = int
          r = work
        end while nil
        r
      end

    private

      def determine_int
        int, extern_h = greatest_node_integer_and_externals
        loop do
          int += 1
          (( x = extern_h[ int ] )) or break
          info_string "avoiding confusing number collision with #{ x }"
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

      def work
        r = Manifest_::Line_edit_[ :at_position_x, 0,
          :new_line_a, @client.render_line_a( @node, @int ),
          * @client.get_subset_a, * @rest_a ]
        r and info_string "done."
        r
      end
    end
  end
end
