module Skylab::Snag

  class Models::Manifest

    class Node_add__ < Agent_

      Snag_::Lib_::Basic_Fields[ :client, self,
        :passive, :absorber, :absrb_iambic_passively,
        :field_i_a, [ :callbacks ] ]

      def initialize x_a
        @node = x_a.shift
        absrb_iambic_passively x_a
        @info_p = Detect_info_p[ x_a ]
        @rest_a = x_a
      end

      Detect_info_p = Snag_::Lib_::Basic_Fields[].iambic_detect.curry[ :info_p ]

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
          info "avoiding confusing number collision with #{ x }"
        end
        int
      end

      def greatest_node_integer_and_externals
        enum = @callbacks.curry_enum.valid
        prefixed_h = { }
        greatest = enum.reduce( -1 ) do |m, node|
          if node.identifier_prefix
            prefixed_h[ node.integer ] = Snag_::Models::Identifier.render(
              node.identifier_prefix, node.identifier_body )
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
          :new_line_a, @callbacks.render_line_a( @node, @int ),
          * @callbacks.get_subset_a, * @rest_a ]
        r and info "done."
        r
      end
    end
  end
end
