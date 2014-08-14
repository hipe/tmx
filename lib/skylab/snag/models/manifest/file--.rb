module Skylab::Snag

  class Models::Manifest::File__  # see [#038], intro at #note-12

    def initialize pathname
      @file_mutex = false
      @fh = nil
      @pathname = pathname
    end

    class Normalized_Line_Producer_
    end

    def normalized_line_producer
      lp = Normalized_Line_Producer_.new
      enum = normalized_lines
      line_number = 0
      lp.define_singleton_method :gets do
        res = nil
        if enum
          begin
            res = enum.next
            line_number += 1
          rescue ::StopIteration
            enum = nil
          end
        end
        res
      end
      lp.define_singleton_method :line_number do line_number end
      pathname = -> { @pathname }
      lp.define_singleton_method :pathname do pathname[ ] end
      lp
    end  # #todo this is unacceptable

    def normalized_lines  # #note-42
      ::Enumerator.new do |y|
        @file_mutex and fail 'sanity'
        @file_mutex = true
        @fh = @pathname.open 'r' # #open-filehandle, #gigo
        begin
          @fh.each do |line|
            y << line.chomp
          end
        ensure
          release_early
        end
      end
    end

    def open?  # #note-52
      @fh
    end

    def release_early
      @file_mutex = nil
      @fh.close
      @fh = nil
    end
  end
end
