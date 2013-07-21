module Skylab::Headless

  module Services::File::Lines

  end

  class Services::File::Lines::Producer < ::Enumerator
                                  # read lines in a more convenient way
                                  # (this is tracked by [#hl-044])
  # #deprecated by Basic::List::Scanner ([#ba-004]) #todo

    def gets
      self.next if @live
    rescue ::StopIteration
    end

    attr_reader :line_number

    attr_reader :pathname

  private

    def initialize pathname
      @fh = nil
      @line_number = nil
      @live = true
      @pathname = pathname  # gigo
      super( ) { |y| visit_fs y }
    end

    def increment_line_number
      if @line_number.nil?
        @line_number = 1
      else
        @line_number += 1
      end
      nil
    end

    def visit_fs y
      @fh and fail 'implement me - file already open'
      @fh = @pathname.open 'r'
      @line_number = nil
      @live = true
      @fh.each_line do |line|
        increment_line_number
        y << line
      end
      @fh.close
      @fh = nil
      @live = nil
      nil
    end
  end
end
