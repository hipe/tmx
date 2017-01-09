module Skylab::Plugin::TestSupport

  module Baseless_Collection

    def self.[] tcc
      tcc.include self
    end

    def shared_state_
      Shared_State___
    end

    def CLI_services_spy_
      CLI_Services_Spy___
    end

    Shared_State___ = ::Struct.new :collection, :services

    class Common_Plugin_Base__

      def initialize _adapter

      end
    end

    class CLI_Services_Spy___

      def initialize do_debug, debug_IO

        @lines_ = []

        @y = if do_debug
          ::Enumerator::Yielder.new do | s |
            debug_IO.puts s.inspect
            @lines_.push s
          end
        else
          ::Enumerator::Yielder.new do | s |
            @lines_.push s
          end
        end
      end

      attr_reader(
        :lines_,
        :y,
      )
    end
  end

  module BC_Namespace

    Common_Plugin_Base = Baseless_Collection::Common_Plugin_Base__

  end
end
