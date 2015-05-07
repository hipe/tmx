module Skylab::System


    class Services___::Environment

      def initialize _
      end

      System_.lib_.properties_stack_frame self,

        :memoized, :proc, :any_home_directory_path, -> do
          ::ENV[ 'HOME' ]
        end,

        :memoized, :inline_method, :any_home_directory_pathname, -> do
          s = any_home_directory_path and ::Pathname.new( s )
        end
    end

end
