module Skylab::Treemap
  class API::FileLinesEnumerator < ::Enumerator
    def close_if_open
      @file.closed? ? nil : (@file.close || true)
    end
    attr_reader :index
    def initialize fh, &blk
      blk and raise ArgumentError("not today.  not today.")
      fh.closed? and fail("pass me an open filehandle please: #{fh.inspect}")
      @index = -1
      @file = fh
      @peeking = nil
      super() do |y|
        @file.lines.each_with_index do |line, index|
          @index = index
          y << line.chomp
        end
      end
    end
    def peeking
      @peeking and return @peeking
      lines = self
      @peeking = Enumerator.new do |y|
        begin
          loop do
            y.yield(lines.peek)
            lines.next
          end
        rescue StopIteration
        end
      end
    end
  end
end

