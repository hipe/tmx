module Skylab::Treemap
  class CLI::Action
    extend Bleeding::Action

    include Treemap::Core::SubClient::InstanceMethods

    def options                   # used by stylus ick to impl. `param`
      option_syntax.options
    end

    def option_syntax             # used all over the place by documentors
      @option_syntax ||= build_option_syntax
    end

  protected

    def initialize                # you get nothing
      super
      @error_count = 0
    end

    def error msg                 # [#044] - - s.c#error ?
      emit :error, msg
      false
    end

    def request_client            # away at [#012]
      @parent
    end

    def wire_api_action api_action
      request_client.send :wire_api_action, api_action
      stylus = request_client.send :stylus     # [#011] unacceptable
      api_action.stylus = stylus
      stylus.set_last_actions api_action, self # **TOTALLY** unacceptable
      nil
    end
  end
end
