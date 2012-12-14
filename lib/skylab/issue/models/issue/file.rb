module Skylab::Issue
  class Models::Issues::File

    def lines
      ::Enumerator.new do |y|
        @file_mutex and fail 'sanity'
        @file_mutex = true
        fh = ::File.open @pathname.to_s, 'r' # #open-filehandle, #gigo
        begin
          fh.each_line do |line|
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
