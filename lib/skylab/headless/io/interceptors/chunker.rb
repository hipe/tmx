module Skylab::Headless

  class IO::Interceptors::Chunker

    # chunker - scan each write of data and emit it in chunks based on separator

    def flush                     # emit out any remaining data. any data
                                  # in the buffer got there thru write and
                                  # so it is guaranteed not to have newlines.
      string = flush_both
      if string.length.nonzero?
        @scn.string = ''
        @func[ string ]
      end
      nil
    end

    def write data
      @buffer.write data
      if @buffer.string.index @separator
        flush_buffer
      end
      nil
    end

  protected

    def initialize func
      @buffer = Headless::Services::StringIO.new
      @separator = "\n"
      @separator_rx = /#{ ::Regexp.escape @separator }/
      @scn = Headless::Services::StringScanner.new ''
      @func = func
    end

    def flush_both
      string = "#{ @scn.rest }#{ @buffer.string }"
      @buffer.rewind
      @buffer.truncate 0
      string
    end
                                               # you are here because there
                                               # is a separator in the nerk
    def flush_buffer
      @scn.string = flush_both
      line = @scn.scan_until @separator_rx
      begin
        @func[ line ]
        line = @scn.scan_until @separator_rx
      end while line
      nil
    end
  end
end
