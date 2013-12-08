module Skylab::Headless

  IO::Upstream::Select = MetaHell::Function::Class.new :select
  class IO::Upstream::Select

    # Select - a chunking, multstream `select` wrapper
    #
    # Select is a stab at non-blocking IO. A Select is composed of a floating-
    # point timeout in seconds and a set of stream / callback pairs, the
    # streams being IO-ishes opened for reading (for e.g STDOUT and STDERR).
    #
    # Load your Select with one or more stream / callback pairs
    # using `on` (see). When you call `select` on your Select, it
    # calls `select` internally, and calls your callbacks as appropriate
    # when data is available in that stream and it makes one or more complete
    # lines (the appropriate callback is called once for each line).
    # When no data is available in any of the streams within the time
    # alloted, an integer representing the total number of bytes read is
    # the result - possibly 0, possibly a billiondy.
    #
    # For now, the input is always chunked into single lines (except the last
    # flush). Work in progres! (tracked by [#048])

    def timeout_seconds= x
      normalize_time x do |flot|
        @accept_timeout_seconds[ flot ]
      end
      x
    end

    # `on` - add a read / write pair.  `io` should be a stream open for
    # reading, and `line` should be a function-ish that responds to `[]`
    # that will receive *non*-chomped lines as they complete from the
    # stream.

    def on io, *rest, &blk
      blk and rest.unshift blk
      rest.unshift io
      0 != rest.length % 2 and raise ::ArgumentError, "must have even no. args"
      ( 0 ... rest.length ).step( 2 ).reduce @add_pair do |y, idx|
        y[ * rest[ idx .. idx + 1 ] ]
        y
      end
      nil
    end

    def heartbeat seconds, &block
      if @set_heartbeat
        normalize_time seconds do |flot|
          @set_heartbeat[ flot, block ]
        end
      else
        raise ::ArgumentError, "can only set heartbeat once."
      end
    end

  private

    def initialize               # no args - mutate exclusively thru the setters
      timeout_seconds = 0.3
      maxlen = Headless::Constants::MAXLEN
      @accept_timeout_seconds = -> x do timeout_seconds = x end
      up_a = [ ] ; down_h = { }
      @add_pair = -> io, line do
        if down_h.key? io.to_i
          raise ::ArgumentError, "attempted to add multiple listeners #{
            }to one stream - this is not yet supported - #{ io }"
        else
          down_h[ io.to_i ] = Headless::IO::Interceptors::Chunker.new line
          up_a << io
        end
      end
      end_of_file = process = flush = heartbeat = init_heartbeat = nil
      @select = -> do
        bytes = 0
        init_heartbeat[]
        while up_a.length.nonzero?
          read_a, _, _ = ::IO.select up_a, nil, nil, timeout_seconds  # #todo at 2.0.0 - `_w`, `_e`
          heartbeat[]
          read_a or break
          read_a.each do |io|
            begin
              str = io.readpartial maxlen
              eof = io.closed?
            rescue ::EOFError
              eof = true
            end
            if str
              bytes += str.length
              process[ io, str ]
            end
            end_of_file[ io ] if eof
          end
        end
        flush[]
        bytes
      end

      process = -> io, str do
        down_h.fetch( io.to_i ).write str
        nil
      end

      end_of_file = -> io do
        down_h.delete( io.to_i ) or fail "sanity"
        idx = up_a.index( io ) or fail "sanity"
        up_a[ idx ] = nil
        up_a.compact!  # eew
        nil
      end

      flush = -> do
        up_a.each do |io|  # (leverage only its order)
          down_h.fetch( io.to_i ).flush
        end
        nil
      end

      -> do   # heartbeat implementation.

        downstream_heartbeat = heartbeat_seconds = t1 = nil

        init_heartbeat = -> do
          t1 = ::Time.now
          nil
        end

        heartbeat = -> { }  # this gets replaced with below when activated

        _heartbeat = -> do
          t2 = ::Time.now
          if ( t2 - t1 ) > heartbeat_seconds
            t1 = t2
            downstream_heartbeat[]
          end
          nil
        end

        @set_heartbeat = -> seconds, block do
          downstream_heartbeat = block
          heartbeat_seconds = seconds
          heartbeat = _heartbeat ; _heartbeat = nil
          @set_heartbeat = nil
        end
      end.call
    end

    def normalize_time x, &valid
      if 0.0 >= x
        raise ::ArgumentError, "must be positive float: #{ x }"
      else
        valid[ 1.0 * x ]
      end
    end
  end
end
