module Skylab::Basic

  class List::Scanner::For::Read

    # [#ba-004] without adding or removing newlines, each call to `gets`
    # results in the next line, ending in e.g. a "\n" iff one existed in the
    # file.
    #
    # `count` will tell you how many lines have been read by gets (0 when
    # the object is first created, 1 after you have successfully `gets`'ed
    # one line, etc).
    #
    # `gets` will result in nil (possibly at the first call) when the end of
    # the file is reached. `gets` can be called any number of subsequent
    # times and will continue to be nil. (filehandle will be closed internally
    # at the first such occurence.)
    #
    # don't expect to find every method that is in other list scanners here.
    # all you get is `gets` and `count` for now.

    def initialize fh
      fh.closed? and raise "expected open filehandle."
      maxlen = Services::Headless::CONSTANTS::MAXLEN
      line_rx = /.*\n|.+/  # not caring for now
      count = 0 ; buffer = ''
      @count = -> { count }
      is_hot = true ; has_buffer = nil
      scn = Services::StringScanner.new ''
      @gets = -> do
        if ! has_buffer
          if is_hot
            x = fh.read maxlen, buffer
            if x
              scn.string = buffer.dup
              has_buffer = true
            else
              is_hot = false
            end
          end
        end
        if has_buffer
          line = scn.scan( line_rx ) and count +=1
          if scn.eos?
            has_buffer = nil
          end
          line
        end
      end
    end

    def count
      @count.call
    end

    def gets
      @gets.call
    end
  end
end
