require File.expand_path('../constants', __FILE__)
require_relative 'models/core'

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
      require ROOT.join("cli/#{name}").to_s
      klass = CLI::Actions.const_get(const)
      action = klass.factory(params) or return action
      action.invoke
    end
  end
  class API::Action
    extend ::Skylab::PubSub::Emitter
    def error msg
      @last_error_message = msg
      emit(:error, msg)
      false
    end
    def invoke
      @last_error_message = nil
      execute
    end
    def pre s ; @stylus.pre s end
    attr_accessor :stylus
  end
end
