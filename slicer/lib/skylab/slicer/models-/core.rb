module Skylab::Slicer

  Models_ = ::Module.new

  Autoloader_[ Models_, :boxxy ]

  # ~ stowaway

  class Action_ < Brazen_::ActionToolkit
    Brazen_::Modelesque.entity self
  end

  # ~ end

  module Models_::No_See  # while #open [#bs-118]

    Actions = ::Module.new

    class Actions::Ping < Action_

      @is_promoted = true

      @instance_description_proc = -> y do
        y << "see how #{ highlight 'well' } this minimal action works"
      end

      def produce_result

        @listener.call :info, :expression do | y |
          y << "hello from slicer."
        end

        :hello_from_slicer
      end
    end
  end
end
