module Skylab::TanMan

  module Input_Adapters_::Treetop

    class Parser__

      def receive_upstream_path path
        receive_byte_upstream_identifier Brazen_.byte_upstream_identifier.via_path path ; nil
      end

      def receive_byte_upstream_identifier x
        @_upstream_ID = x ; nil
      end

      def receive_parser_class cls
        @_parser_class = cls ; nil
      end

      def flush_to_parse_tree

        prs = @_parser_class.new

        #  prs.consume_all_input = false  # e.g

        syntax_node = prs.parse @_upstream_ID.whole_string

        if syntax_node
          syntax_node.tree
        else
          @parser_failure_reason = prs.failure_reason
          UNABLE_
        end
      end

      attr_reader :parser_failure_reason

    end
  end
end
# :#tombstone: this used to be must more overwrought and hookable
