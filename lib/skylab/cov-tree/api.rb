require File.expand_path('../constants', __FILE__)
require File.expand_path('../../../skylab', __FILE__)
require 'skylab/slake/muxer'

module Skylab::CovTree
  class << self
    def api
      @api ||= Api.new
    end
  end
  class Api
    def invoke_porcelain name, params
      const = name.to_s.gsub(/([a-z])-([a-z])/) { "#{$1}#{$2.capitalize}" }.capitalize
      klass = Porcelain.const_get(const)
      action = klass.factory(params) or return action
      action.invoke
    end
  end
end

