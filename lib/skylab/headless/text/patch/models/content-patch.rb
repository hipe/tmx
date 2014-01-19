module Skylab::Headless

  class Services::Patch::Models::ContentPatch  # builds a patch progressively.

    def initialize content_x
      @chunks = []
      if ! content_x.respond_to? :gets
        content_x = Headless::Services::Basic::List::Scanner[ content_x ]
      end
      @lines = content_x
      @offset = 0 ; nil
    end

    def change_line num, new_line
      change_lines num, [new_line]
    end

    def change_lines range, new_lines
      range = range .. range if ::Fixnum === range
      rbeg = range.begin
      rend = range.end
      offs = 0
      if range.exclude_end?
        fail "`exclude_end?` ranges must be zero-width" unless rbeg == rend
      end
      chunk = Services::Patch::Models::Chunk.new
      line = @lines.gets
      fail 'range begin too low' if @lines.line_number > rbeg
      line = @lines.gets while line && @lines.line_number < rbeg
      if ! line
        if range.exclude_end? && 1 == ( rend - @lines.line_number )
          offs = 1
        else
          fail 'range begin too high'
        end
      end
      chunk.left.range.begin = @lines.line_number + offs
      chunk.right.range.begin = @lines.line_number + @offset + offs
      chunk.left << line if ! range.exclude_end?
      while @lines.line_number < rend
        line = @lines.gets
        if line
          chunk.left << line
        elsif range.exclude_end? && 1 == ( rend - @lines.line_number )
          break
        else
          fail 'range end too high'
        end
      end
      new_lines = new_lines.dup
      while line = new_lines.shift
        chunk.right << line
      end
      @offset += ( chunk.right.line_count - chunk.left.line_count )
      @chunks.push chunk
      nil
    end

    def render_simple
      io = Headless::Services::StringIO.new
      write_simple io
      io.rewind
      io.read
    end

    -> do
      range = -> r do
        case r.begin <=> r.end
        when 0  ; "#{ r.begin }"
        when -1 ; "#{ r.begin },#{ r.end }"
        else    ; "#{ r.end }"
        end
      end

      define_method :write_simple do |io|
        @chunks.each do |c|
          lf = c.left.length.nonzero?
          rt = c.right.length.nonzero?
          letter = if lf
                     if rt then 'c' else 'd' end
                   elsif rt then 'a'
                   else fail 'wahooo'
                   end
          io.puts(
            "#{ range[ c.left.range ] }#{letter}#{ range[ c.right.range ] }" )
          c.left.lines.each do |l|
            io.puts "< #{ l }"
          end
          io.puts "---" if lf && rt
          c.right.lines.each do |l|
            io.puts "> #{ l }"
          end
        end
        nil
      end

    end.call
  end
end
