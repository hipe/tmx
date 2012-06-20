require 'skylab/interface/system'

module Skylab::Treemap
  class R::Bridge
    extend Skylab::PubSub::Emitter
    emits :info, :error

    include Skylab::Interface::System
    attr_reader :executable_name
    def executable_path
      @ready.nil? and ! ready? and return false
      @executable_path or @ready
    end
    def initialize
      @executable_name = 'R'
      @ready = nil
      yield(self) if block_given?
    end
    def not_ready msg
      @ready = false
      @not_ready_reason = msg
      false
    end
    attr_reader :not_ready_reason
    def ready?
      if ! @ready.nil? # this may change, or get a reset etc
        return @ready
      end
      unless @executable_path = sys.which(executable_name)
        return not_ready(%{executable by this name is not in the PATH: "#{executable_name}"})
      end
      @ready = true
    end
  end
end

