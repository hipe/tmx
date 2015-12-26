module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___  # see [#010]

      def initialize s, rx

        _match_scanner = Here_::Match_Scanner___.new s, rx

        _line_scanner = Here_::Line_Scanner_.new s

        _scanners = Scanners___.new _match_scanner, _line_scanner

        @first_block = Here_::Block___.via_scanners _scanners

        @ruby_regexp = rx
        @string = s
      end

      Scanners___ = ::Struct.new :match_scanner, :line_scanner

      def set_path_and_ordinal path, d
        @ordinal = d
        @path = path ; nil
      end

      # --

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
