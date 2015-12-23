module Skylab::SearchAndReplace

  module Magnetics_::Read_Only_File_Session_Stream_via_File_Session_Stream

    class << self
      def [] up, & p
        Sessioner___.new up, & p
      end
    end  # >>

    class Sessioner___

      def initialize up, & oes_p

        @__prototype = Session___.new(
          up.ruby_regexp,
          up.do_highlight,
          & oes_p )
      end

      def produce_file_session_via_ordinal_and_path d, path
        @__prototype.new d, path
      end
    end

    class Session___

      def initialize rx, yes, & p

        @do_highlight = yes
        @ruby_regexp = rx

        @_oes_p = p
        freeze
      end

      def new d, path
        dup.___init_copy d, path
      end

      def ___init_copy d, path
        @ordinal = d
        @path = path
        freeze
      end

      attr_reader(
        :ordinal,
        :path,
        :ruby_regexp,
      )

      def to_read_only_match_stream
        to_read_only_match_stream_when_multi_line
      end

      # -

        def to_read_only_match_stream_when_multi_line
          match = Read_Only_Match___.new @path, @do_highlight
          whole_file = ::File.read @path
          line_number = 1
          last_begin = 0
          beg_pos = 0
          with_match = -> md do

            this_begin, next_begin = md.offset 0

            # advance current line number
            d = whole_file.index NEWLINE_, last_begin
            while d && d < this_begin
              line_number += 1
              d = whole_file.index NEWLINE_, d + 1
            end
            last_begin = this_begin

            # find any leading string between match and beginning of line
            d = this_begin
            while d.nonzero?
              d -= 1
              if NEWLINE_CHAR__ == whole_file.getbyte( d )
                d += 1
                break
              end
            end
            if d < this_begin
              before_match = whole_file[ d ... this_begin ]
            end

            # find any trailing string between match and end of line
            # don't bother if final character of match is the delimiter
            d = whole_file.index NEWLINE_, ( next_begin - 1 )
            if d && d >= next_begin
              after_match = whole_file[ next_begin .. d ]
            end

            beg_pos = next_begin
            match.dup_with_args line_number, before_match, md, after_match
          end
          p = -> do
            md = @ruby_regexp.match whole_file, beg_pos
            if md
              with_match[ md ]
            else
              p = EMPTY_P_
              nil
            end
          end
          Callback_.stream do
            p[]
          end
        end

        NEWLINE_CHAR__ = NEWLINE_.getbyte 0

        def __to_read_only_match_stream_when_single_line__  # #open [#007]
          io = ::File.open @path, ::File::CREAT | ::File::RDONLY
          line_number = 0
          rx = @ruby_regexp
          Callback_.stream do
            while line = io.gets
              line_number += 1
              md = rx.match line
              if md
                x = match.dup_with_args md, line_number, line
                break
              end
            end
            x
          end
        end

        class Read_Only_Match___

          def initialize path, yes
            @do_highlight = yes
            @path = path
            freeze
          end

          def dup_with * x_a
            dup.init_copy_via_iambic x_a
          end

          def dup_with_args * a
            dup.___init_copy a
          end

           def ___init_copy a
             @lineno, @before_match, @md, @after_match = a
             freeze
           end

           def init_copy_via_iambic x_a
             x_a.each_slice 2 do |i, x|  # or whatever
               send :"#{ i }=", x
             end
             freeze
           end

         public

          def members
            [ :md, :lineno, :lines, :path ]
          end

          attr_reader :lineno, :md, :path

          attr_writer :do_highlight

          def lines
            to_line_stream.to_a
          end

          def to_line_stream
            p = stream = nil
            s = s_ = nil
            finish = -> do
              p = EMPTY_P_ ; nil
            end
            main = -> do
              if s_
                x = s
                s = s_
                s_ = stream.gets
                x
              else
                finish[]
                "#{ s }#{ @after_match }"
              end
            end
            p = -> do
              stream = Home_.lib_.basic::String.line_stream @md[ 0 ]
              if @do_highlight
                stream = stream.map_by do |string|
                  did = string.chomp!
                  "\e[1;32m#{ string }\e[0m#{ NEWLINE_ if did }"
                end
              end
              s = stream.gets
              if s
                s_ = stream.gets
                if s_
                  p = main
                  x = "#{ @before_match }#{ s }"
                  s = s_
                  s_ = stream.gets
                  x
                else
                  finish[]
                  "#{ @before_match }#{ s }#{ @after_match }"
                end
              else
                finish[]
              end
            end
            Callback_.stream do
              p[]
            end
          end
        end  # read only match
      # -
    end  # session
  end  # magnetic
end
