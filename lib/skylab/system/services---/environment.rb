module Skylab::Headless

  module System__

    class Services__::Environment

      Headless_::Lib_::Properties_stack_frame.call self,

        :memoized, :proc, :any_home_directory_path, -> do
          ::ENV[ 'HOME' ]
        end,

        :memoized, :inline_method, :any_home_directory_pathname, -> do
          s = any_home_directory_path and ::Pathname.new( s )
        end

      def initialize _system_front
        super() do end
      end
    end
  end
end
