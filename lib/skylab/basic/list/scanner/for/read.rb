module Skylab::Basic

  List::Scanner::For::Read = MetaHell::Function::Class.new :count, :gets
  class List::Scanner::For::Read

    # [#004] without adding or removing newlines, each call to `gets`
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
      maxlen = Services::Headless::Constants::MAXLEN
      line_rx = /.*\n|.+/  # not caring for now
      count = 0 ; buffer = ''
      @count = -> { count }
      is_hot = true ; buffer_is_loaded = nil
      scn = Services::StringScanner.new buffer
      load_buffer = -> do
        x = fh.read maxlen, buffer
        if x
          scn.string = buffer
          buffer = ''
          buffer_is_loaded = true
          true
        else
          is_hot = false
          false
        end
      end
      @gets = -> do
        if is_hot
          line = nil
          while true
            buffer_is_loaded or load_buffer[] or break
            part = scn.scan line_rx
            if part
              if line
                line.concat part
              else
                line = part
              end
              part.include? "\n" and break
            else
              buffer_is_loaded = false
            end
          end
          count +=1 if line
          line
        end
      end
    end
  end
end
