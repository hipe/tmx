module Skylab::TestSupport
  class EmitSpy < ::Struct.new :stack, :debug, :format

    # Acts as an interceptor for *only* emit(), which writes each such
    # event to a stack (presumably for immediate subsequent test assertion)
    # and optionally writes a somehow-formatted version of the event to
    # a debugging stream.
    #

    def clear!
      stack.clear
    end

    def do_debug
      debug.call if self[:debug]
    end

    def do_debug= b
      self.debug = -> { b }
      b
    end

    def debug!
      self.do_debug = true
      self
    end

    def no_debug!
      self.do_debug = false
      self
    end

    def emit type, *payload                    # per spec [#ps-001]
      do_debug and $stderr.puts format[ type, * payload ]
      if payload.empty?
        stack.push type                        # your witness
      else
        stack.push [ type, *payload ]
      end
      nil
    end

    def format
      if ! self[:format]
        self[:format] = -> type, *payload do   # per spec [#ps-001]
          if payload.empty? and type.respond_to?(:string)
            type.string
          else
            [type, *payload].inspect
          end
        end
      end
      super
    end

  protected

    def initialize &format_for_debug
      super [], nil, format_for_debug
    end
  end
end
