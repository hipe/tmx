require File.expand_path('../constants', __FILE__)
require 'skylab/slake/muxer'

module Skylab::CovTree
  class << self
    def api
      @api ||= Api.new
    end
  end
  class Api
    def invoke_porcelain name, params
      (name = name.to_s) =~ /\A[-a-z]+\z/ or fail("nope: #{name.inspect}")
      const = name.gsub(/([a-z])-([a-z])/) { "#{$1}#{$2.capitalize}" }.capitalize
      require ROOT.join('porcelain').join(name).to_s
      klass = Porcelain.const_get(const)
      action = klass.factory(params) or return action
      action.invoke
    end
  end
end

