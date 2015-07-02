module Skylab::Slicer

  module Models_::Transfer

    Autoloader_[ ( Actions = ::Module.new ), :boxxy ]

    class Action_ < Brazen_::Action
      Brazen_::Model::Entity.call self
    end

    class Actions::Ping < Action_

      @is_promoted = true

      def produce_result

        @on_event_selectively.call :info, :expression do | y |
          y << "hello from slicer."
        end
        :hello_from_slicer
      end
    end
  end
end
