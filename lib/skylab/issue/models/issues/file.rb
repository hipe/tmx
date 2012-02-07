module Skylab::Issue
  class Models::Issues::File
    def clear
      if @fh
        @fh.close # might throw...
      end
      @fh = nil
      self
    end
    def each_line &b
      _file.each_line(&b)
      clear
    end
    def _file
      @fh ||= begin
        @path.exist? or fail("path must exist to use #{self.class} : #{@path}")
        File.open(@path.to_s, 'r')
      end
    end
    def initialize path
      @path = path
    end
    # from stack overflow #3024372, thank you molf
    # def tail ; ... end
  end
end

