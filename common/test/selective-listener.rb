require_relative '../test-support'

module Skylab::Common::TestSupport::Selective_Listener

  ::Skylab::Common::TestSupport[ TS__ = self ]

  include Constants

  Home_ = Home_

  extend TestSupport_::Quickie

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
      Home_::Selective_Listener
    else
      Home_::Selective_Listener[ * x_a ]
    end
  end
end
