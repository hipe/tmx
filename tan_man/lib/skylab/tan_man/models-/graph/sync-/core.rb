module Skylab::TanMan

  class Models_::Graph

    class Sync_  # see [#026] narrative

      def initialize inp, herep, outp, bx, kr, & oes_p
        @box_proxy = bx
        @do_build_transient_graph = false
        @dot_file_silo = kr.silo :dot_file
        @here_ID = herep
        @in_ID = inp
        @kernel = kr
        @on_event_selectively = oes_p
        @only_write_hereput_to_output = false
        @out_ID = outp
      end

      attr_accessor :do_build_transient_graph, :only_write_hereput_to_output

      def flush
        if @only_write_hereput_to_output
          __only_write_hereput_to_output
        else
          _ok = __resolve_input_lines
          _ok && __normal
        end
      end

      def __only_write_hereput_to_output

        if @here_ID.is_same_waypoint_as @out_ID
          @on_event_selectively.call :error, :hereput_and_output_waypoints_are_the_same
          UNABLE_
        else
          _store :@dc, _via_here_ID_build_document_controller
        end
      end

      def __resolve_input_lines
        @line_count = 0
        st = @in_ID.to_simple_line_stream
        st and begin
          @in_ID = nil
          @upstream_lines = Common_::MinimalStream.by do
            line = st.gets
            if line
              @line_count += 1
            end
            line
          end
          ACHIEVED_
        end
      end

      def __normal

        if @do_build_transient_graph
          __resolve_session_with_transient_graph
        else
          _via_hereput_resolve_session
        end
        @sync_session and __mutate_session_and_write_to_output
      end

      def __resolve_session_with_transient_graph
        @here_ID = Byte_upstream_reference_[].via_string "digraph{\n}\n"
        _via_hereput_resolve_session
      end

      def _via_hereput_resolve_session
        @sync_session = begin
          @dc = _via_here_ID_build_document_controller
          @dc and begin
            Sync_::Session___.new @dc, @kernel, & @on_event_selectively
          end
        end
      end

      def _via_here_ID_build_document_controller
        @dot_file_silo.document_controller_via_byte_upstream_reference(
          @here_ID, & @on_event_selectively )
      end

      def __mutate_session_and_write_to_output
        ok = __process_first_line
        ok &&= __process_zero_or_more_label_nodes
        ok &&= __process_zero_or_more_edges
        ok &&= __process_last_line
        ok && __finish
      end

      # ~ matching only

      def __process_first_line
        @line = @upstream_lines.gets
        if @line && FIRST_LINE_RX___ =~ @line
          ACHIEVED_
        else
          _when_expected :opening_digraph_line
        end
      end

      FIRST_LINE_RX___ =
        /\A[[:space:]]*digraph[[:space:]]*\{[[:space:]]*(?:#.*)?\n\z/i

      def __process_zero_or_more_label_nodes
        @line = @upstream_lines.gets
        @seen_labels = false
        @md = if @line
          LABEL_LINE_RX__.match @line
        end
        ok = true
        if @md
          @seen_labels = true
          ok = _via_label_match
          begin
            ok or break
            @line = @upstream_lines.gets
            @line or break
            @md = LABEL_LINE_RX__.match @line
            @md or break
            ok = _via_label_match
            redo
          end while nil
        end
        ok
      end

      node_ID = '[a-zA-Z_][a-zA-Z_0-9]*'
      _quot = '(?:[^"\\\\]+|\\\\.)*'

      LABEL_LINE_RX__ = /\A
        [[:space:]]* (?<id>#{ node_ID })
        [[:space:]]* \[
          [[:space:]]* label
          (?: [[:space:]]* =? | [[:space:]]+ )
          [[:space:]]* "(?<quot>#{ _quot })"
        [[:space:]]* \]
        [[:space:]]* (?:\#.+)?\n
      \z/x

      def __process_zero_or_more_edges
        @seen_edges = false
        ok = true
        @md = if @line
          EDGE_RX__.match @line
        end
        if @md
          @seen_edges = true
          ok = _via_edge_match
          begin
            ok or break
            @line = @upstream_lines.gets
            @line or break
            @md = EDGE_RX__.match @line
            @md or break
            ok = _via_edge_match
            redo
          end while nil
        end
        ok
      end

      EDGE_RX__ = /\A
        [[:space:]]* (?<source_node> #{ node_ID } )
        [[:space:]]* ->
        [[:space:]]* (?<target_node> #{ node_ID } )
        [[:space:]]* (?:\#.*)? \n
      \z/x

      def __process_last_line

        if LAST_LINE_RX___ =~ @line
          @line = @upstream_lines.gets
          if @line
            __TODO_when_unexpected_input_after_end
          else
            ACHIEVED_
          end
        else
          i_a = []
          if @seen_labels
            if @seen_edges
              i_a.push :edge_line
            else
              i_a.push :label_line
            end
          elsif @seen_edges
            i_a.push :edge_line
          else
            i_a.push :label_line
            i_a.push :edge_line
          end
          i_a.push :closing_digraph_line
          _when_expected( * i_a )
        end
      end

      LAST_LINE_RX___ = /\A[[:space:]]*\}[[:space:]]*(?:#.*)?\n?\z/

      def _when_expected * i_a

        @on_event_selectively.call :error, :input_parse_error do
          __build_parse_eror_event i_a
        end
        UNABLE_
      end

      def __build_parse_eror_event i_a

        h = {
          opening_digraph_line: "digraph{",
          label_line: "foo [label=\"Foo\"]",
          edge_line: "foo -> bar",
          closing_digraph_line: "}"
        }

        Common_::Event.inline_not_OK_with :input_parse_error,

            :lineno, @line_count,
            :line, @line,
            :tuples, i_a.map { |i| [ i, h.fetch( i ) ] } do | y, o |

          _s_a = o.tuples.map do | sym, eg_s |
            "#{ sym.id2name.gsub( UNDERSCORE_, SPACE_ ) }#{
              } (e.g #{ eg_s.inspect })"
          end

          if o.line
            _prep_phrase = " near line #{ o.lineno }: #{ o.line.inspect }"
          else
            _prep_phrase = " at end of input"
          end
          y << "expecting #{ _s_a * ' or ' }#{ _prep_phrase }"
        end
      end

      # ~ processing

      def _via_label_match

        s = @md[ :quot ]
        s.gsub!( /\\(.)/ ) do
          TEMP_H___.fetch $~[ 1 ]
        end
        @sync_session.receive_node @md[ :id ], s
      end
      TEMP_H___ = {  # etc this doesn't belong here, is done elsewhere
        '"' => '"'
      }

      def _via_edge_match
        @sync_session.receive_edge( @md[ :source_node ], @md[ :target_node ] )
      end

      def __finish
        @sync_session.receive_finish
      end

      def the_document_controller
        @dc
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end
  end
end
