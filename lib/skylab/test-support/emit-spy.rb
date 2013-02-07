module Skylab::TestSupport
  class EmitSpy

    # Acts as an interceptor for *only* emit(), which writes each such
    # event to a stack (presumably for immediate subsequent test assertion)
    # and optionally writes a somehow-formatted version of the event to
    # a debugging stream.
    #

    def clear!
      @emitted.clear
    end

    def do_debug
      @debug.call if @debug
    end

    def do_debug= b
      @debug = -> { b }
      b
    end

    def debug= callable
      raise ::ArgumentError.new('callable?') if ! callable.respond_to?( :call )
      @debug = callable
    end

    def debug!
      self.do_debug = true
      self
    end

    def no_debug!
      self.do_debug = false
      self
    end

    Event_Mote = ::Struct.new :stream_name, :string, :payload # similar to [#ts-007]

    def emit stream, *payload      # per spec [#ps-001]
      do_debug and $stderr.puts format[ stream, * payload ]
      case payload.length
      when 0
        if ::Symbol === stream
          em = Event_Mote.new stream
        else
          em = Event_Mote.new stream.stream_name, stream.message
        end
      when 1
        if ::String === payload.first
          em = Event_Mote.new stream, payload.first
        else
          em = Event_Mote.new stream, nil, payload.first
        end
      else
        em = Event_Mote.new stream, nil, payload
      end
      @emitted.push em
      nil
    end

    attr_reader :emitted

    def format
      @format ||= begin
        -> type, *payload do   # per spec [#ps-001]
          if payload.length.zero? and type.respond_to?( :string )
            type.string
          else
            [ type, *payload ].inspect
          end
        end
      end
    end

    def format= callable
      raise ::ArgumentError.new( "callable?" ) if ! callable.respond_to?(:call)
      @format = callable
    end

  protected

    def initialize &format_for_debug
      @debug = nil
      @format = format_for_debug
      @emitted = []
    end
  end
end
