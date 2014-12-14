module Skylab::BeautySalon

  class Models_::Search_and_Replace

    module Actors_::Build_file_scan

      class Models__::Read_Only_File_Session

        class << self

          def producer_via_iambic x_a
            ok = nil
            x = Producer__.new do
              ok = process_iambic_stream_fully iambic_stream_via_iambic_array x_a
            end
            ok && x
          end
        end

        class Producer__

          Callback_::Actor.methodic self, :simple, :properties,

            :property, :ruby_regexp,
            :ignore, :property, :grep_extended_regexp_string,
            :property, :do_highlight,
            :ignore, :property, :max_file_size_for_multiline_mode,
            :property, :on_event_selectively


          def initialize
            @do_highlight = nil
            super
            @prototype = Self_.new @ruby_regexp, @do_highlight, @on_event_selectively
          end

          def produce_file_session_via_ordinal_and_path d, path
            @prototype.dup_with_ordinal_and_path d, path
          end
        end

        def initialize * a
          @ruby_regexp, @do_highlight, @on_event_selectively = a
          freeze
        end

        def dup_with_ordinal_and_path d, path
          dup.init_copy d, path
        end

      protected

        def init_copy d, path
          @ordinal = d
          @path = path
          freeze
        end

      public

        def members
          [ :ordinal, :path, :ruby_regexp ]
        end

        attr_reader :ordinal, :path, :ruby_regexp

        def to_read_only_match_stream
          to_read_only_match_stream_when_multi_line
        end

        def to_read_only_match_stream_when_multi_line
          match = Read_Only_Match__.new @path, @do_highlight
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

        def __to_read_only_match_stream_when_single_line__  # when [#024] explicit choice
          io = ::File.open @path, READ_MODE_
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

        class Read_Only_Match__

          def initialize *a
            @path, @do_highlight = a
            freeze
          end

          def dup_with * x_a
            dup.init_copy_via_iambic x_a
          end

          def dup_with_args * a
            dup.init_copy a
          end

         protected

           def init_copy a
             @line_number, @before_match, @md, @after_match = a
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
            [ :md, :line_number, :lines, :path ]
          end

          attr_reader :line_number, :md, :path

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
              stream = BS_::Lib_::String_lib[].line_stream @md[ 0 ]
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
        end

        Self_ = self
      end
    end
  end
end
