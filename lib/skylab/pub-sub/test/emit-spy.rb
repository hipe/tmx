module Skylab::PubSub::TestSupport

  class Emit_Spy

    # Set this up somehow as an interceptor for `emit` and it will cache
    # each such emission that it gets into `emission_a`, presumably for
    # subsequent test assertion of it.
    #
    # To keep life easy (for now) it assumes a payload datapoint of
    # exactly 1 in its `emit` arity. To keep life simple (but not easy),
    # it will not assume anything about the shape of your one datapoint
    # (although you wish it would assume it is text).
    #
    # its `do_debug` state is derived from a function that you can set
    # with `debug=`, so that your debugging state does not have to be
    # determined at the time that you create this object and send it off
    # somewhere, but rather can be linked e.g to a different object's
    # debugging state.
    #
    # When debugging is on (when `do_debug` resolves to trueish), each
    # call to `emit` will result in a `puts` to the `stdinfo` stream
    # (stderr by default), with an inspectified version of the emission.
    #

    #         ~ the primary public method ~

    def emit stream, payload_x      # per spec [#ps-001]
      @emission_a << Emit_Spy::Emission.new( stream, payload_x )
      if @debug && @debug.call
        o = @emission_a.last
        @stdinfo.puts [ o.stream_name, o.payload_x ].inspect
      end
      nil
    end

    #         ~ debugging, which internally is a proc ~

    def do_debug
      @debug.call if @debug
    end

    def do_debug= b
      self.debug = -> { b }
      b
    end

    def debug= callable
      raise ::ArgumentError.new('callable?') if ! callable.respond_to?( :call )
      @stdinfo ||= ::STDERR
      @debug = callable
    end

    def debug!
      self.do_debug = true
      nil
    end

    def no_debug!
      self.do_debug = false
      nil
    end

    attr_writer :stdinfo

    #         ~ retrieving and deleting emissions ~

    def clear!
      @emission_a.clear
    end

    attr_reader :emission_a

    def delete_emission_a
      res = @emission_a
      @emission_a = nil
      res
    end

  private

    def initialize &format_for_debug
      @debug = nil
      @format = format_for_debug
      @emission_a = []
      @stdinfo = nil
    end

    Emit_Spy = self  # (just for readability above)
  end

  class Emit_Spy::Emission

    attr_reader :stream_name

    attr_reader :payload_x

    def initialize stream_name, payload_x
      @stream_name, @payload_x = stream_name, payload_x
    end
  end
end
