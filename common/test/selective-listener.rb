module Skylab::Common::TestSupport

  module Selective_Listener

    def self.[] tcc
      tcc.include InstanceMethods___
    end

    module InstanceMethods___

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

      def subject_module_
        Home_::Selective_Listener
      end
    end
  end
end
