module Skylab::CovTree

  class API::Action
    extend CovTree::Core::Action

    extend PubSub::Emitter

    ANCHOR_MODULE = CovTree::API::Actions

  protected

    def error msg
      @last_error_message = msg
      emit :error, msg
      false
    end
  end
end
