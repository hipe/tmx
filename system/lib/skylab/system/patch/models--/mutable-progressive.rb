module Skylab::System

  module Patch

    class Models__::Mutable_Progressive  # builds a patch progressively.

      class << self

        def new_via_file_content_before_ content_x
          new do
            __init_via_file_content content_x
          end
        end

        private :new
      end  # >>

      def initialize & edit_p

        @_chunks = []
        @_offset = 0

        if block_given?
          instance_exec( & edit_p )
        end
      end

      def __init_via_file_content x

        @_lines = if x.respond_to? :gets
          x
        else
          Common_::SimpleStream.try_convert x
        end
        NIL_
      end

      def apply_to_path_on_system * x_a, path, system_conduit, & x_p

        x_a.push :target_file, path
        x_a.push :system_conduit, system_conduit
        x_a.push :patch_lines, to_line_stream

        Home_.services.patch.call_via_arglist x_a, & x_p
      end

      def to_patch_string
        s = ""
        to_line_stream.each do | line |
          s.concat line
        end
        s
      end

      def to_line_stream

        __to_chunk_stream.expand_by do | chunk |
          chunk.to_line_stream
        end
      end

      def __to_chunk_stream
        Common_::Stream.via_nonsparse_array @_chunks
      end


      def change_line lineno, new_line

        change_lines lineno, [ new_line ]
      end

      def change_lines r, new_lines

        r = __normalize_range r

        begin_ = r.begin
        end_ = r.end
        up = @_lines

        line = up.gets

        if up.lineno > begin_
          fail __say_two
        end

        while line && up.lineno < begin_
          line = up.gets
        end

        d = 0
        if ! line
          if r.exclude_end? && 1 == ( end_ - up.lineno )
            d = 1
          else
            fail __say_three
          end
        end

        chunk = Models__::Chunk.new
        chunk.left.range.begin = up.lineno + d
        chunk.right.range.begin = up.lineno + @_offset + d

        if ! r.exclude_end?
          chunk.left << line
        end

        while up.lineno < end_
          line = up.gets
          if line
            chunk.left << line
          elsif r.exclude_end? && 1 == ( end_ - up.lineno )
            break
          else
            fail __say_four
          end
        end

        rt = chunk.right
        new_lines.each do | line_ |
          rt << line_
        end

        @_offset += ( chunk.right.line_count - chunk.left.line_count )
        @_chunks.push chunk

        ACHIEVED_
      end

      def __normalize_range r

        if r.respond_to? :bit_length
          r = r .. r
        end

        if r.exclude_end? && r.begin != r.end
          fail __say_one
        end

        r
      end

      def __say_one
        "`exclude_end?` ranges must be zero-width"
      end

      def __say_two
        'range begin too low'
      end

      def __say_thee
        'range begin too high'
      end

      def __say_four
        'range end too high'
      end
    end
  end
end
