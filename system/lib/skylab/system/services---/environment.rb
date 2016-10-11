module Skylab::System


    class Services___::Environment

      def initialize _
      end

      Home_.lib_.attributes_stack_frame self,

        :memoized, :proc, :any_home_directory_path, -> do
          ::ENV[ 'HOME' ]
        end,

        :memoized, :inline_method, :any_home_directory_pathname, -> do
          s = any_home_directory_path
          if s
            Home_.lib_.pathname.new s
          end
        end
    end

end
