module Skylab::TanMan

  class Models_::Graph::Actions::Sync

    class Sync_via_Parameters___ < Common_::MagneticBySimpleModel

      # see [#026] IO resolution through parameter modeling, near syncing.

      def initialize
        super
      end

      attr_writer(
        :here_reference,
        :in_reference,
        :listener,
        :microservice_invocation,
        :out_reference,
      )

      # (it "feels" more parsimonious if we again make a logic mesh here,
      #  but with the making of different decisions than we did there.
      #  with some fragility we omit the cases that we failed out before.)

      def execute
        if @in_reference
          if @here_reference
            if @out_reference
              __when_input_and_hereput_and_output  # case 1
            else
              __when_input_and_hereput  # case 2
            end
          else
            __when_input_and_output  # case 3
          end
        else
          __when_hereput_and_output  # case 5
        end
      end

      # -- H:

      def __when_input_and_hereput

        ok = _not_same :_input_, :_hereput_
        ok && self._SKETCH__in_pseudocode__
      end

      def __when_input_and_hereput_and_output

        ok = _not_same :_input_, :_hereput_
        ok &&= _not_same :_hereput_, :_output_
        ok && self._SKETCH__in_pseudocode__
      end

      def __when_input_and_output

        ok = _not_same :_input_, :_output_
        ok &&= _resolve_upstream_line_stream_via :_input_
        ok && _will_begin_with_empty_document
        ok && _will_write_final_output_lines_to( :_output_ )
        ok && _money
      end

      def __when_hereput_and_output

        ok = _not_same :_hereput_, :_output_
        ok &&= self._HMMM
      end

      def _money

        ok = __process_first_line
        ok && self._README  # you're gonna wanna go ahead and use DigraphSession_via_THESE
        ok &&= __process_zero_or_more_label_nodes
        ok &&= __process_zero_or_more_edges
        ok &&= __process_last_line
        ok && __finish
      end

      # -- G: matching

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
          sym_a = []
          if @seen_labels
            if @seen_edges
              sym_a.push :edge_line
            else
              sym_a.push :label_line
            end
          elsif @seen_edges
            sym_a.push :edge_line
          else
            sym_a.push :label_line
            sym_a.push :edge_line
          end
          sym_a.push :closing_digraph_line
          _when_expected( * sym_a )
        end
      end

      LAST_LINE_RX___ = /\A[[:space:]]*\}[[:space:]]*(?:#.*)?\n?\z/

      def _when_expected * sym_a

        @listener.call :error, :input_parse_error do
          __build_parse_eror_event sym_a
        end
        UNABLE_
      end

      def __build_parse_eror_event sym_a

        h = {
          opening_digraph_line: "digraph{",
          label_line: "foo [label=\"Foo\"]",
          edge_line: "foo -> bar",
          closing_digraph_line: "}"
        }

        _tuples = sym_a.map do |sym|
          [ sym, h.fetch( sym ) ]
        end

        _lineno = send @_lineno

        Common_::Event.inline_not_OK_with(
          :input_parse_error,
          :lineno, _lineno,
            :line, @line,
          :tuples, _tuples,
        ) do |y, o|

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

      # -- F: processing

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

      # -- E:

      def _will_write_final_output_lines_to sym

        $stderr.puts "(IGNORING A THING)"
        @__document_controller = nil  # NOTE - ..

        @sync_session = This_::ExposedClient_for_Session___.new(
          remove_instance_variable( :@__document_controller ),
          @microservice_invocation,
          & @listener )
        NIL
      end

      # -- D:

      def _will_begin_with_empty_document

        _ref = Byte_upstream_reference_[].via_string "digraph{\n}\n"
        @USE_BYTE_UPSTREAM_REFERENCE = _ref
        NIL
      end

      # -- C:

      def _resolve_upstream_line_stream_via whatput

        _ref = instance_variable_get _ivar whatput

        st = _ref.to_minimal_line_stream  # ..

        if st
          if st.respond_to? :lineno
            @_lineno = :__line_number_easily
            @upstream_lines = st
          else
            @_lineno = :__line_number_complicatedly
            @upstream_lines = __wrap_so_we_have_line_numbers st
          end
          ACHIEVED_
        end
      end

      def __wrap_so_we_have_line_numbers st
        @_current_line_number = 0
        Common_::MinimalStream.by do
          line = st.gets
          if line
            @_current_line_number += 1
            line
          end
        end
      end

      def __line_number_complicatedly
        @_current_line_number
      end

      def __line_number_easily
        @upstream_lines.lineno
      end

      # -- B:

      def _not_same whatput, whatput_

        ref = instance_variable_get _ivar whatput
        ref_ = instance_variable_get _ivar whatput_

        if ref.is_same_waypoint_as ref_

          _channel_tail = case [ whatput, whatput_ ]
          when [ :_hereput_, :_output_ ]
            :hereput_and_output_waypoints_are_the_same
          else
            self._COVER_ME__easy__
          end

          @listener.call :error, _channel_tail
          UNABLE_
        else
          ACHIEVED_
        end
      end

      # -- A: general support

      def _ivar whatput
        case whatput
        when :_input_ ; :@in_reference
        when :_hereput_ ; :@here_reference
        when :_output_ ; :@out_reference
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end
  end
end
# #history-A.1: first half of rewrite (perhaps last half too)
