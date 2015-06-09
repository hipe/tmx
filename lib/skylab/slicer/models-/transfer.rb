module Skylab::Slicer

  module Models_::Transfer

    Actions = ::Module.new

    class Actions::Ping < Brazen_::Action

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
