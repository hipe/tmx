module Skylab::TestSupport

  class IO::Spy__::Triad__ < ::Struct.new :instream, :outstream, :errstream

    # [#031] WILL SUNSET. use "io spy group" for all new work
    # see [#020] a comparison of different IO spy aggregations

    def initialize *three
      @do_debug = nil
      three.length > 3 and raise ::ArgumentError, "it's three bro"
      1.upto( 3 ) do |len|  # (allow caller to pass intentional nils..)
        if three.length < len
          three[ len - 1 ] = Home_::IO.spy.new
        end
      end
      super
    end

    attr_reader :do_debug  # just to see if you called `debug!`

    def debug! prepnd=nil
      @do_debug = true
      members.each do |i|
        x = self[ i ]
        x or next
        if x.respond_to? :debug!
          x.debug! prepnd
        else  # assume it is an [#sy-014] IO tee. ignoring `prepnd` for now
          x[ :debug ] = Prefixed_debugging_IO__[ i, Home_.debug_IO ]
        end
      end
      nil
    end

    Prefixed_debugging_IO__ = -> do

      p = -> i, io do

        Prefixed_Debugging_IO__ =
          Home_.lib_.basic::Proxy::Makers::Functional::Nice.new(
            :puts, :write, :<<, :rewind, :truncate )

        p = -> i_, io_ do
          fmt = -> x do
            "(#{ i_ }: #{ x.inspect })"
          end
          me = Prefixed_Debugging_IO__.new(
            :<<, -> x do
              io_ << fmt[ x ] ; me
            end,
            :puts, -> x do
              io_.puts fmt[ x ]
            end,
            :write, -> x do
              io_.write fmt[ x ]
              x.length
            end,
            :rewind, -> do
              io_.rewind
            end,
            :truncate, -> x do
              if io_.respond_to? :truncate
                io_.truncate x
              else
                0  # meh
              end
            end
          )
        end
        p[ i, io ]
      end
      -> i, io do
        p[ i, io ]
      end
    end.call

    def clear_buffers
      values.each( & :clear_buffer )
      nil
    end
  end
end
