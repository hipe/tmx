module Skylab::TanMan

  module Input_Adapters_::Treetop

    Autoloader_[ Sessions = ::Module.new ]

    class Sessions::Parse

      def accept_upstream_path path

        _bu_ID =  Brazen_.byte_upstream_identifier.via_path path
        receive_byte_upstream_identifier _bu_ID
        NIL_
      end

      def receive_byte_upstream_identifier x
        @_upstream_ID = x ; nil
      end

      def accept_parser_class cls
        cls or self._SANITY
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

    Models_ = ::Module.new
    class Models_::Grammar_to_Load

      attr_accessor(
        :input_path,
        :make_this_directory_minus_p,
        :module_name_i_a,
        :output_path,
        :output_path_did_exist,
      )
    end

    Treetop_ = self
  end
end
# :#tombstone: this used to be must more overwrought and hookable
