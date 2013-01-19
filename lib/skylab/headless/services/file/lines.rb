module Skylab::Headless
  class Services::File::Lines < ::Enumerator
                                  # read lines in a more convenient way
                                  # (this is tracked by [#hl-044])

    def gets
      self.next if @live
    rescue ::StopIteration
    end

    attr_reader :line_number

    attr_reader :pathname

  protected

    def initialize pathname
      @fh = nil
      @line_number = nil
      @live = true
      if ::Array === pathname
        @lines = pathname
        super( ) { |y| visit_no_fs y }
      else
        @pathname = ::Pathname.new pathname
        super( ) { |y| visit_fs y }
      end
    end

    def line_number!
      if @line_number
        @line_number += 1
      else
        @line_number = 1
      end
    end

    def visit_fs y
      @fh and fail 'implement me - file already open'
      @fh = @pathname.open 'r'
      @line_number = nil
      @live = true
      @fh.each_line do |line|
        line_number!
        y << line
      end
      @fh.close
      @fh = nil
      @live = nil
      nil
    end

    def visit_no_fs y
      @lines or fail 'implement me - lines exhausted'
      @line_number = nil
      @live = true
      while @lines.length.nonzero?
        line = @lines.shift
        line_number!
        y << line
      end
      @lines = nil
      @live = nil
      nil
    end
  end
end
