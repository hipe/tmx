require_relative '../test-support'

module Skylab::Callback::TestSupport::Listener

  ::Skylab::Callback::TestSupport[ TS__ = self ]

  include CONSTANTS

  Callback = Callback

  extend TestSupport::Quickie

  module InstanceMethods
    def client
      @client ||= build_client
    end
    def emitter
      @emitter ||= build_emitter
    end
    def listener
      @listener ||= build_listener
    end
    def subject
      @subject ||= build_subject
    end
  end
end
