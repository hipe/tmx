module Skylab::TanMan
  class Models::Model
    extend Bleeding::DelegatesTo
    extend Porcelain::AttributeDefiner

    delegates_to :emitter, :emit

    attr_reader :emitter

    def error e
      invalid_reasons.push e
      emit(:error, e)
    end

    def initialize emitter
      @emitter = emitter
      @invalid_reasons = []
      super
    end

    attr_reader :invalid_reasons

    # this is very not complete. needs hooking in with meta attributes some how..
    def valid?
      invalid_reasons.size.zero? or return false
      required_ok?
      invalid_reasons.size.zero?
    end
  end
end

