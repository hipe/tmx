module Skylab::System::TestSupport

  module Doubles::Stubbed_Filesystem

    def self.[] tcc

      tcc.send(
        :define_singleton_method,
        :dangerous_memoize_,
        TestSupport_::DANGEROUS_MEMOIZE,
      )

      tcc.include Instance_Methods___
    end

    module Instance_Methods___
    private

      def subject_module_
        Home_::Doubles::Stubbed_Filesystem
      end

      def at_ sym
        CONSTANTS___.lookup sym
      end
    end

    class CONSTANTS___ < TestSupport_::Lazy_Constants

      define_method :COMMON_STUBBED_FS_MANIFEST_PATH_ do

        ::File.join TS_.dir_path, 'doubles', 'stubbed-filesystem', 'fixtures', 'paths.manifest'
      end
    end
  end
end
