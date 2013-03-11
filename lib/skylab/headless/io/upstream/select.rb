module Skylab::Headless

  class IO::Upstream::Select

    # Select - a chunking, multstream select wrapper
    #
    # Select is a stab at non-blocking IO. A Select is composed of a timeout
    # in seconds and one or more callbacks that corresponds to a set of one
    # or more streams to read from. The streams are set with the `streams`
    # box and the hooks are set with the `line` box (for now this chunks output
    # into lines). When you call `select` on the Select object, it
    # calls `select` internally, and calls your callbacks as appropriate
    # when data is available in that stream and it makes one or more complete
    # lines (the appropriate callback is called once for each line.)
    # When no data is available in any of the streams within the time
    # alloted, an integer representing the total number of bytes read is
    # the result - possibly 0, possibly a billiondy.
    #
    # For now, the input is always chunked into single lines (except the last
    # flush). Work in progres! (tracked by [#hl-048])


    attr_reader :line

    def select
      bytes = 0
      while @remaining_a.length.nonzero?
        read, _w, _e = ::IO.select @remaining_a, nil, nil, @timeout_seconds
        read or break
        read.each do |io|
          begin
            str = io.readpartial @maxlen
            eof = io.closed?
          rescue ::EOFError => e
            eof = true
          end
          if str
            bytes += str.length
            received io, str
          end
          self.eof( io ) if eof
        end
      end
      flush
      bytes
    end

    attr_reader :stream

    def timeout_seconds= x
      0.0 >= x and raise ::ArgumentError, "must be positive float: #{ x }"
      @timeout_seconds = x.to_f
      x
    end

  protected

    def initialize                # no args - manipulate exclusively thru
      @timeout_seconds = 0.3      # the setters
      @maxlen = Headless::CONSTANTS::MAXLEN  # private for now but trivial etc
      @remaining_a = [ ]          # streams we are still reading
      @stream_name_h = { }        # reverse-lookup stream's name

      @line = MetaHell::Formal::Box.new.tap do |box|
        class << box
          alias_method :[]=, :add
          public :[]=
        end
      end

      stream_ok, stream_added = method( :stream_ok ), method( :stream_added )

      @stream = MetaHell::Formal::Box.new.tap do |box|
        box.define_singleton_method :[]= do |k, v|
          if stream_ok[ k, v ]
            add k, v
            stream_added[ k, v ]
          end
          v
        end
      end

      @downstream = MetaHell::Formal::Box.new.tap do |box|
        class << box
          public :add
        end
      end
      nil
    end

    def eof io
      @remaining_a[ @remaining_a.index io ] = nil
      @remaining_a.compact!
      nil
    end

    def flush
      @downstream.each { |o| o.flush }
      nil
    end

    def name_lookup io
      @stream_name_h.fetch io.object_id
    end

    def received io, str
      @downstream.fetch( name_lookup io ).write str
      nil
    end

    def stream_added k, v
      @remaining_a << v
      @stream_name_h[ v.object_id ] = k
      chnk = Headless::IO::Interceptors::Chunker.new @line.fetch( k )
      @downstream.add k, chnk
      nil
    end

    def stream_ok k, v
      raise ::NameError, "won't add stream when there is no hook - #{ k }" if
        ! line.has? k
      true
    end
  end
end
