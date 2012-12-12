module Skylab::CovTree

  class CLI::Action
    extend CovTree::Core::Action

    include CLI::Styles

    ANCHOR_MODULE = CovTree::CLI::Actions

  protected

    def api_action_class
      API::Actions.const_fetch normalized_name
    end

    def emit *a
      request_client.emit(* a)
    end

    def error msg
      emit :error, msg
      false
    end

    def info msg
      emit :info, msg
      nil
    end

    def payload str
      emit :payload, str
      nil
    end
  end
end
