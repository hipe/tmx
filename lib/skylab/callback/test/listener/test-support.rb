require_relative '../test-support'

module Skylab::Callback::TestSupport::Listener

  ::Skylab::Callback::TestSupport[ TS__ = self ]

  include CONSTANTS

  Callback = Callback

  Callback::Lib_::Quickie[ self ]

  module InstanceMethods
    def client
      @client ||= build_client
    end
    def emitter
      @emitter ||= build_digraph_emitter
    end
    def listener
      @listener ||= build_listener
    end
    def subject
      @subject ||= build_subject
    end
  end
end
