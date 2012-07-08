require File.expand_path('../constants', __FILE__)
require 'skylab/pub-sub/emitter'

module Skylab::CovTree
  class << self
    def api
      @api ||= API.new
    end
  end
  class API
    module Actions
    end
    def invoke_porcelain name, params
      (name = name.to_s) =~ /\A[-a-z]+\z/ or fail("nope: #{name.inspect}")
      const = name.gsub(/([a-z])-([a-z])/) { "#{$1}#{$2.capitalize}" }.capitalize
      require ROOT.join("porcelain/#{name}").to_s
      klass = CLI::Actions.const_get(const)
      action = klass.factory(params) or return action
      action.invoke
    end
  end
end

