require 'skylab/interface/system'

module Skylab::Treemap
  class R::Bridge
    extend Skylab::PubSub::Emitter
    emits :info, :error

    include Skylab::Interface::System
    attr_reader :executable_name
    attr_reader :executable_path
    def initialize
      @executable_name = 'R'
      @ready = nil
      yield(self) if block_given?
    end
    def not_ready msg
      emit(:error, msg)
      @ready = false
    end
    def ready?
      if ! @ready.nil? # this may change, or get a reset etc
        return @ready
      end
      unless @executable_path = sys.which(executable_name)
        return not_ready(%{not in PATH: "#{executable_name}"})
      end
      @ready = true
    end
  end
end

