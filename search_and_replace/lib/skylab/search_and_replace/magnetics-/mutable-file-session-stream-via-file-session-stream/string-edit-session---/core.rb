module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___  # see [#010].  # #testpoint

      def initialize is_dry, s, d, path, repl_f, rx

        _match_scanner = Here_::Match_Scanner___.new s, rx

        _line_scanner = Here_::Line_Scanner_.new s

        _scanners = Scanners___.new _match_scanner, _line_scanner, repl_f

        @first_block = Here_::Block___.via_scanners _scanners

        @is_dry_run = is_dry
        @ordinal = d
        @path = path
        @ruby_regexp = rx
        @string = s
      end

      Scanners___ = ::Struct.new(
        :match_scanner,
        :line_scanner,
        :replacement_function,
      )

      def initialize_dup otr  # [#014] only for tests :/
        @first_block.next_block
        @first_block = @first_block.dup.init_dup_recursive_ nil
      end

      # --

      def write_output_lines_into y, & oes_p  # convenience for the lazy..

        bytes = 0  # maybe ..
        st = to_line_stream
        begin
          s = st.gets
          s or break
          y << s
          bytes += s.length
          redo
        end while nil

        if block_given?
          oes_p.call :info, :data, :number_of_bytes_written do
            bytes
          end
        end

        y
      end

      def to_line_stream
        ___to_block_stream.expand_by do | block |
          block.to_output_line_stream__
        end
      end

      def ___to_block_stream

        block = self
        Callback_.stream do
          block = block.next_block
          block
        end
      end

      def first_match_controller
        @first_block.next_match_controller
      end

      alias_method :next_match_controller, :first_match_controller  # for stream algos only

      attr_reader(
        :is_dry_run,
        :ordinal,
        :first_block,
        :path,
        :ruby_regexp,
        :string,
      )

      alias_method :next_block, :first_block
      protected :next_block

      Here_ = self
      NEWLINE_SEXP_ = [ :newline_sequence, NEWLINE_ ].freeze
      NOTHING_ = nil  # in contrast with something
    end
  end
end
