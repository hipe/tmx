require 'skylab/interface/system'

module Skylab::Treemap
  class R::Bridge
    include Skylab::Interface::System
    attr_reader :executable_name
    attr_reader :executable_path
    def initialize
      @executable_name = 'R'
      @ready = false
    end
    def ready?
      @ready and return true
      unless @executable_path = sys.which(executable_name)
        self.not_ready_reason = %{not in PATH: "#{executable_name}"}
        return false
      end
      @ready = true
    end
    attr_accessor :not_ready_reason
  end
end

