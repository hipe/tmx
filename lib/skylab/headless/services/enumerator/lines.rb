module Skylab::Headless

  module Services::Enumerator
    module Lines
    end
  end

  class Services::Enumerator::Lines::Producer < ::Enumerator

    # add `gets` to an enumerator.

    def gets
      self.next if @hot
    rescue ::StopIteration
      @hot = nil
    end

  protected

    def initialize
      super
      @hot = true
    end
  end
end
