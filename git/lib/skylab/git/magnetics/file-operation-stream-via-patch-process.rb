module Skylab::Git

  class Magnetics::FileOperationStream_via_PatchProcess

    class << self
      def via_sha sha, cmd_proto, sys, & p
        _process = ProcessOfShowCommand_via_SHA___[ sha, cmd_proto, sys, & p ]
        new( _process, & p ).execute
      end
      private :new
    end  # >>

    def initialize process, & p
      @listener = p
      @process = process
    end

    def execute
      @_method = :__first_gets
      Common_.stream do
        send @_method
      end
    end

    def __first_gets
      @_open = true
      @_stream = @process.out
      line = @_stream.gets
      if line
        line.chomp!
        @_line = line
        __first_gets_normally
      else
        _process_failure.execute
        _failed
      end
    end

    def __first_gets_normally

      @_method = :__subsequent_gets

      if @_line.length.nonzero?
        _assume HEADER_OF_PATCH___
      end

      _consume_blank_line
      _consume_diff_line
      _consume_file_operation
    end

    def __subsequent_gets
      _assume_diff_line
      _consume_file_operation
    end

    def _consume_file_operation
      _consume_file_operation_line
      _m = OPERATIONS___.fetch @_operation
      _wahoo = send _m
      _wahoo  # #todo
    end

    OPERATIONS___ = {
      change: :__consume_index_section,
      create: :__consume_create_section,
      delete: :__consume_delete_section,
      rename: :__consume_rename_section,
    }

    def _consume_file_operation_line
      _consume_line
      md = _assume OPERATIONS_RX___
      @_operation = if md[ :index ]
        :change
      elsif md[ :similarity_index ]
        :rename
      elsif md[ :deleted ]
        :delete
      else
        :create
      end
      NIL
    end

    OPERATIONS_RX___ = /\A
      (?:
        (?<index>index)
        |
        (?<similarity_index>similarity[ ]index)
        |
        (?<deleted>deleted)
        |
        (?<new_file>new[ ]file)
      )\b
    /x

    # --
    # ~

    def __consume_create_section

      _consume INDEX_RX__  # the empty file may have been added, so:

      _consume_any_line
      if @_open

        _md = _assume DIFF_LINE_OR_MMM_RX__
        if _md[ :minus_minus_minus ]
          _assume MINUS_MINUS_MINUS_DEV_NULL_RX___
          _consume_plus_plus_plus_on_after_path
          _consume_chunks
        else
          NOTHING_  # (hi. section ended without chunks - blank file.)
          # (the parse is left with the current line as the diff line)
        end
      end

      Home_::Models::FileOperations::Create.new @_after
    end  # :#here

    # ~

    def __consume_index_section  # assume current line is index line
      @_before == @_after || self._SANITY  # #excercize
      _consume_chunks_body
      Home_::Models::FileOperations::Change.new @_before
    end

    # ~

    def __consume_rename_section
      __consume_rename_from_line
      __consume_rename_to_line
      _consume_any_line
      if @_open
        _md = _assume DIFF_LINE_OR_INDEX_LINE_RX___
        if _md[ :index ]
          # this rename also has edits
          _consume_chunks_body
        end
      end
      Home_::Models::FileOperations::Rename.new @_before, @_after
    end

    def __consume_rename_from_line
      _consume_line
      @_from = _assume( FROM_RX___ )[ :from ]
      NIL
    end

    FROM_RX___ = /\Arename from (?<from>.+)\z/

    def __consume_rename_to_line
      _consume_line
      @_to = _assume( TO_RX___ )[ :to ]
      NIL
    end

    TO_RX___ = /\Arename to (?<to>.+)\z/

    # ~

    def __consume_delete_section

      # (this is a mirror-image counterpart to create section #here)

      _consume INDEX_RX__  # the empty file may have been added, so:

      _consume_any_line
      if @_open

        _md = _assume DIFF_LINE_OR_MMM_RX__
        if _md[ :minus_minus_minus ]

          _assume_minus_minus_minus_on_before_path
          _consume PLUS_PLUS_PLUS_DEV_NULL_RX___
          _consume_chunks
        else
          NOTHING_  # (hi. - file that was deleted was the blank file.)
        end
      end

      Home_::Models::FileOperations::Delete.new @_before
    end

    # --

    def _consume_chunks_body
      _consume_minus_minus_minus_on_before_path
      _consume_plus_plus_plus_on_after_path
      _consume_chunks
    end

    def _consume_chunks
      _consume CHUNK_HEADER_RX__
      _consume_raw_line
      begin
        __assume_maybe_chunk_line
        @_line_looks_like_a_chunk_line || break
        _consume_any_raw_line
        @_open ? redo : break
      end while above
      NIL
    end

    def __assume_maybe_chunk_line
      _md = _assume CHUNK_OR_OTHER_RX___
      if _md[ :chunk_line ]
        @_line_looks_like_a_chunk_line = true
      else
        @_line_looks_like_a_chunk_line = false
        @_line.chomp!
      end
      NIL
    end

    def _consume_diff_line
      _consume_line
      _assume_diff_line
    end

    def _assume_diff_line
      md = _assume DIFF_LINE_RX___
      @_before = md[ :before ] ; @_after = md[ :after ] ; nil
    end

    def _consume_minus_minus_minus_on_before_path
      _consume_line
      _assume_minus_minus_minus_on_before_path
    end

    def _assume_minus_minus_minus_on_before_path
      _path = _assume( MINUS_MINUS_MINUS_RX___ )[ :path ]
      _path == @_before || self._SANITY  # just exercize
    end

    def _consume_plus_plus_plus_on_after_path
      _consume_line
      _assume_plus_plus_plus_on_after_path
    end

    def _assume_plus_plus_plus_on_after_path
      _path = _assume( PLUS_PLUS_PLUS_RX__ )[ :path ]
      _path == @_after || self._SANITY  # just exercize
    end

    HEADER_OF_PATCH___ = %r(\A(?<tag>[^,]+),(?<branch>.+)\z)

    DIFF_LINE_RX___ = %r(\A
      diff[ ]--git[ ]a/(?<before>[^ ]+)[ ]b/(?<after>[^ ]+)
    \z)x

    DIFF_LINE_OR_INDEX_LINE_RX___ = /\A(?:(?<diff>diff)|(?<index>index)) /

    DIFF_LINE_OR_MMM_RX__ = /\A(?:(?<minus_minus_minus>--- )|(?<diff>diff ))/

    INDEX_RX__ = /\Aindex /

    MINUS_MINUS_MINUS_RX___ = %r(\A--- a/(?<path>.+)\z)
    PLUS_PLUS_PLUS_RX__ = %r(\A\+\+\+ b/(?<path>.+)\z)

    MINUS_MINUS_MINUS_DEV_NULL_RX___ = %r(\A--- /dev/null\z)
    PLUS_PLUS_PLUS_DEV_NULL_RX___ = %r(\A\+\+\+ /dev/null\z)

    CHUNK_HEADER_RX__ = %r(\A@@ )

    CHUNK_OR_OTHER_RX___ = /\A
      (?:
        (?<chunk_line>
          [-+@ ] |
          \\[ ]No[ ]newline[ ]at[ ]end[ ]of[ ]file  # No newline at end of file
        )
        |
        (?<other>[a-z])  # ballsy
      )
    /x

    # --

    def _consume rx
      _consume_line
      _assume rx
    end

    def _assume rx
      md = rx.match @_line
      if ! md
        self._REGEX_ASSUMPTION_FAILURE
      end
      md
    end

    def _consume_blank_line
      _consume_line
      _assume_blank_line
    end

    def _assume_blank_line
      @_line.length.zero? || self._ASSUMPTION_FAILED
      NIL
    end

    def _consume_line
      _consume_raw_line
      @_line.chomp! ; nil
    end

    def _consume_raw_line
      s = @_stream.gets
      s || fail
      @_line = s ; nil
    end

    def _consume_any_line
      _consume_any_raw_line
      if @_open
        @_line.chomp!
      end
      NIL
    end

    def _consume_any_raw_line
      s = @_stream.gets
      if s
        @_line = s
      else
        __close
      end
      NIL
    end

    def __close

      @_open = false
      @_method = :__nothing
      remove_instance_variable :@_line

      err = @process.err.gets
      if err
        _process_failure.when_stderr_line err
      else
        d = @process.wait.value.exitstatus
        if d.nonzero?
          _process_failure.when_nonzero_exitstatus d
        end
      end
      NIL
    end

    # --

    def _process_failure
      Magnetics::Expression_via_Process_that_ProbablyFailed[ @process, & @listener ]
    end

    def _failed
      @_method = :__nothing
      UNABLE_
    end

    def __nothing
      NOTHING_
    end

    # ==

    class ProcessOfShowCommand_via_SHA___
      extend ProcLike_

      def initialize sha, cmd_proto, sys, & p
        @__command_prototype = cmd_proto
        @__listener = p
        @__sha = sha
        @__system = sys
      end

      def execute
        __init_command
        __build_process
      end

      def __init_command
        a = remove_instance_variable( :@__command_prototype ).dup
        a.concat SHOW_COMMAND___
        a.push remove_instance_variable :@__sha
        @_command = a ; nil
      end

      def __build_process
        @__listener.call( :info, :command ) { @_command }
        _a = remove_instance_variable( :@__system ).popen3( * @_command )
        Process_[ * _a, @_command ]
      end

      # ==

      SHOW_COMMAND___ = %w( show -M --format=%D )
    end
  end
end
# #history: abstracted from one-off
