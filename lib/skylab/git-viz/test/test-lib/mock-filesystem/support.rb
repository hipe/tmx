module Skylab::GitViz::TestSupport::Test_Lib

  module Mock_Filesystem::Support

    def self.[] tcc

      tcc.send :define_singleton_method,
        :dangerous_memoize_,
        TestSupport_::DANGEROUS_MEMOIZE

      tcc.include Instance_Methods___
    end

    module Instance_Methods___
    private

      def subject_module_
        Subject_module_[]::Mock_Filesystem
      end

      def at_ sym
        CONSTANTS___.lookup sym
      end
    end

    class CONSTANTS___ < Lazy_Constants_

      define_method :COMMON_MOCK_FS_MANIFEST_PATH_ do

        TS_.dir_pathname.join( 'mock-filesystem/fixtures/paths.manifest' ).to_path
      end
    end
  end
end
