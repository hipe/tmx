module Skylab::TestSupport
  class EmitSpy < ::Struct.new(:stack, :do_debug, :formatter)
    def initialize &formatter
      super([], false, formatter)
    end
    def clear!
      stack.clear
    end
    def debug!
      self.do_debug = true
      self.formatter ||= ->(*e){ e = e.first if 1 == e.length ; (e.respond_to?(:string) ? e.string : e.to_s) }
      self
    end
    def no_debug!
      self.do_debug = false
      self
    end
    def emit *payload
      do_debug and $stderr.puts(formatter.call(*payload))
      1 == payload.length and payload = payload.first # could become an option
      stack.push payload
      nil
    end
  end
end
