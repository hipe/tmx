module Skylab::SearchAndReplace

    class StringEditSession_  # see [#010].  # #testpoint

      def initialize is_dry, s, d, path, repl_f, rx

        _match_scanner = Here_::Match_Scanner___.new s, rx

        _line_scanner = Here_::Line_Scanner_.new s

        cls = Here_::Block_

        _ = cls::Ingredients.new _line_scanner, _match_scanner, repl_f

        @first_block = cls.via_ingredients__ _

        @is_dry_run = is_dry
        @ordinal = d
        @path = path
        @ruby_regexp = rx
        @string = s
      end

      def initialize_dup otr  # [#014] only for tests :/
        @first_block = @first_block.duplicate_first_block__
        NIL_
      end

      # --

      def write_output_lines_into y, & p  # convenience for the lazy..

        bytesize = 0
        st = to_line_stream
        begin
          s = st.gets
          s or break
          y << s
          bytesize += s.bytesize
          redo
        end while nil

        if block_given?
          p.call :info, :data, :number_of_bytes_written do
            bytesize
          end
        end

        y
      end

      def to_line_stream
        to_throughput_line_stream_.map_by do |tl|
          tl.to_unstyled_bytes_string_
        end
      end

      def to_throughput_line_stream_
        ___to_block_stream.expand_by do |block|
          block.to_throughput_line_stream_
        end
      end

      def ___to_block_stream  # #testpoint

        block = self
        Common_.stream do
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
      NOTHING_ = nil  # in contrast with something
    end
end
