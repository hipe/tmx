require_relative '../test-support'

module Skylab::Callback::TestSupport::Selective_Listener

  ::Skylab::Callback::TestSupport[ TS__ = self ]

  include Constants

  Callback_ = Callback_

  Callback_::Lib_::Quickie[ self ]

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

  Subject_ = -> * x_a do
    if x_a.length.zero?
      Callback_::Selective_Listener
    else
      Callback_::Selective_Listener[ * x_a ]
    end
  end
end
