require File.expand_path('../../../skylab', __FILE__)

require 'skylab/slake/muxer' # assume children will want it

module Skylab::Issue

  ISSUES_FILE = 'doc/issues.md'

  class Api
    def initialize &events
      @events = events
    end
    def invoke name, context
      require File.expand_path("../api/#{name}", __FILE__)
      klass = self.class.const_get(name.to_s.gsub(/(?:^|-)([a-z])/) { $1.upcase })
      _events = @events
      klass.new(context){ instance_eval(& _events) }.invoke
    end
  end
end

