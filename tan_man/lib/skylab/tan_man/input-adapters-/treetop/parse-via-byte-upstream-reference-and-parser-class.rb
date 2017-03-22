module Skylab::TanMan

  module Input_Adapters_::Treetop

    Autoloader_[ Sessions = ::Module.new ]

    class Sessions::Parse

      def initialize & oes_p
        @on_event_selectively = oes_p
      end

      def accept_upstream_path path

        _bu_ID = Byte_upstream_reference_[].via_path path
        receive_byte_upstream_reference _bu_ID
        NIL_
      end

      def receive_byte_upstream_reference x
        @_upstream_ID = x ; nil
      end

      def accept_parser_class cls
        cls or self._SANITY
        @_parser_class = cls ; nil
      end

      def flush_to_parse_tree

        sn = flush_to_syntax_node
        if sn
          sn.tree
        else
          sn
        end
      end

      def flush_to_syntax_node

        @_parse = @_parser_class.new

        #  prs.consume_all_input = false  # e.g

        s = _produce_whole_string
        if s
          x = @_parse.parse @_upstream_ID.whole_string
          if x
            x
          else
            self._COVER_ME_FUN_emit_this_instead
            @parser_failure_reason = @_parse.failure_reason
            UNABLE_
          end
        else
          s
        end
      end

      def parser_failure_reason
        self._JUST_CHECKING
      end

      # attr_reader :parser_failure_reason

      def _produce_whole_string

        begin
          @_upstream_ID.whole_string

        rescue ::Errno::ENOENT => e

          ev = Common_::Event.wrap.exception e, :path_hack

          @on_event_selectively.call :error, ev.terminal_channel_symbol do
            ev
          end
          UNABLE_
        end
      end
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

    Here_ = self
  end
end
# :#tombstone: this used to be must more overwrought and hookable
