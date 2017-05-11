module Skylab::TanMan

  class Models_::Graph::Actions::Sync

    class Sync_via_Parameters___ < Common_::MagneticBySimpleModel

      # [#026.B] describes syncing

      def initialize
        super
          @_is_dry_run = remove_instance_variable :@is_dry_run
      end

      attr_writer(
        :here_reference,
        :in_reference,
          :is_dry_run,
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

        def __when_input_and_hereput_and_output  # a proper syncing, non-destructive

          if _not_same :_input_, :_hereput_ and _not_same :_hereput_, :_output_
            _with_locked_line_counting_upstream_via :_input_ do
              _with_digraph_that_we_wont_mutate :@here_reference, :@out_reference do
                _money
              end
            end
          end
        end

        def __when_input_and_hereput  # a proper syncing that is destructive

          if _not_same :_input_, :_hereput_
            _with_locked_line_counting_upstream_via :_input_ do
              __with_digraph_that_we_will_mutate :@here_reference do
                _money
              end
            end
          end
        end

      def __when_input_and_output

          # a bit of a motion test: starting with an empty document,
          # exercise our hand-written parsing hack to "sync" all the input
          # lines into the empty digraph, and express it to the output.

          if _not_same :_input_, :_output_
            _with_locked_line_counting_upstream_via :_input_ do

              @__empty_ref = Byte_upstream_reference_[].via_string "digraph{\n}\n"

              _with_digraph_that_we_wont_mutate :@__empty_ref, :@out_reference do
                _money
              end
            end
          end
      end

      def __when_hereput_and_output

          # again this is a bit of a simple exercise of machinery:
          # see if you can resolve a digraph document from the input.
          # if it works, merely echo out each line to the output.

          if _not_same :_hereput_, :_output_
            _with_digraph_that_we_wont_mutate :@here_reference, :@out_reference do
              DID_WORK_  # really this just simplifies testing. could be any trueish
            end
          end
      end

        # --

        def _with_digraph_that_we_wont_mutate ivar, ivar_, & work

          bsr = remove_instance_variable ivar
          bsr_ = remove_instance_variable ivar_

          _digraph_session_by work do |o|
            o.two_byte_stream_references__ bsr, bsr_
            o.be_read_write_not_read_only_
          end
        end

        def __with_digraph_that_we_will_mutate ivar, & work

          bsr = remove_instance_variable ivar

          if ! bsr.is_writable
            bsr = bsr.to_read_writable
          end

          _digraph_session_by work do |o|
            o.byte_stream_reference = bsr
            o.be_read_write_not_read_only_
          end
        end

        def _digraph_session_by work

          Models_::DotFile::DigraphSession_via_THESE.call_by do |o|

            yield o

            o.session_by do |dc|
              @_digraph_controller = dc
              x = work[]
              remove_instance_variable :@_digraph_controller
              x || NIL_AS_FAILURE_
            end
            o.is_dry_run = @_is_dry_run  # only relevant if we write
            o.microservice_invocation = @microservice_invocation
            o.listener = @listener
          end
        end

        def _with_open_output_stream ivar

          _bsr = remove_instance_variable ivar

          obs = _open_by_stream_by do |o|
            o.byte_stream_reference = _bsr
            o.be_for_write_only
          end

          if obs
            bsr = obs.sanitized_byte_stream_reference
            @_open_downstream = bsr
            x = yield
            remove_instance_variable :@_open_downstream
            if obs.is_lockable_and_locked
              obs.close_stream_and_release_lock_  # stay close to #spot3.1
            end
            x
          end
        end

        def _open_by_stream_by

          Mags_[]::OpenByteStream_via_ByteStreamReference.call_by do |o|
            yield o
            o.filesystem = @microservice_invocation.invocation_resources.filesystem
            o.listener = @listener
          end
        end

      # --

      def _money
          __init_sync_session
          ok = __process_first_line
        ok &&= __process_zero_or_more_label_nodes
        ok &&= __process_zero_or_more_edges
        ok &&= __process_last_line
        ok && __finish
      end

        def __init_sync_session
          @sync_session = This_::ExposedClient_for_Session___.define do |o|
            o.digraph_controller = @_digraph_controller
            o.listener = @listener
          end
          NIL
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
        NIL
      end

      # -- D:
        # (used to be something)

      # -- C:

        def _with_locked_line_counting_upstream_via whatput

          _byte_upstream_ref = instance_variable_get _ivar whatput

          obs = _open_by_stream_by do |o|
            o.byte_stream_reference = _byte_upstream_ref
            o.be_for_read_only
          end

          if obs
            min_st = obs.sanitized_byte_stream_reference.to_minimal_line_stream  # ..
            if min_st
              min_st = __produce_use_minimal_stream_and_init_line_number_reader_via min_st
              __init_comment_free_line_stream_via_line_counting_line_stream min_st
              x = yield
            end
            if obs.is_lockable_and_locked
              obs.close_stream_and_release_lock_  # stay close to #spot3.1
            end
            x
          end
        end

        def __init_comment_free_line_stream_via_line_counting_line_stream min_st

          if false  # (see notes there)
          min_st = Minimal_line_stream_without_comments_via_minimal_line_stream___[ min_st ]
          end
          @upstream_lines = min_st  # (legacy name)
          NIL
        end

        def __produce_use_minimal_stream_and_init_line_number_reader_via st
          if st.respond_to? :lineno
            @_lineno = :__line_number_easily
            @__line_counting_line_stream = st
            st
          else
            @_lineno = :__line_number_complicatedly
            __wrap_so_we_have_line_numbers st
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
          @__line_counting_line_stream.lineno
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

      # ==

      Minimal_line_stream_without_comments_via_minimal_line_stream___ = -> st do

        # at first we thought we needed this to pass legacy tests, but no..
        # nonetheless we have kept the sketch here

        Common_::MinimalStream.by do
          begin
            line = st.gets
            line || break
            # ..
            self._ETC__this_would_take_some_rearranging__
            break
          end while above
          line
        end
      end

      # ==
      # ==
    end
  end
end
# #history-A.1: first half of rewrite (perhaps last half too)
