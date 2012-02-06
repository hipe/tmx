module Skylab::Issue
  class Api::Action
    def initialize context, &events
      @params = context
      instance_eval(&events)
    end
    def invoke
      # we leave room *maybe* for a slake-like pattern (rake like)
      execute
    end
  end
end

