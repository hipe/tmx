module Skylab::Snag
  class Models::Node::File
    # (this is used by services and hence cannot be a sub-client!)

    # `normalized_line_producer` is like a filehandle that you call `gets`
    # on (in that when you reach the end of the file it returns nil)
    # but a) you don't have to chomp each line and b) it keeps track
    # of the line number internally for you (think of it as like a
    # ::StringScanner but instead of for scanning over bytes in a string
    # it is for scanning lines in a file).

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
    end


    # `normalized_lines` is comparable to File#each (aka `each_line`, `lines`)
    # except a) it internalizes the fact that it is a file, taking care of
    # closing the file for you, and b) it chomps each line, so you don't have
    # to worry about whether your line happens to be the last in the file,
    # or whether or not the last line in the file ends with newline characters,
    # or what those characters are.

    def normalized_lines
      ::Enumerator.new do |y|
        @file_mutex and fail 'sanity'
        @file_mutex = true
        fh = @pathname.open 'r' # #open-filehandle, #gigo
        begin
          fh.each do |line|
            y << line.chomp
          end
        ensure
          fh.close
          @file_mutex = nil
        end
      end
    end

    # (from stack overflow #3024372, thank you molf for a tail-like
    # implementation if we ever need it)

  protected

    def initialize pathname
      @file_mutex = false
      @pathname = pathname
    end
  end
end
