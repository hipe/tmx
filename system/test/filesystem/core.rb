module Skylab::System::TestSupport

  module Filesystem::Normalizations

    def self.[] tcm
      Want_Event[ tcm ]
      tcm.include self
    end

    # -
      def against_ path
        @result = subject_via_plus_real_filesystem_plus_listener_(
          :path, path,
        )
        NIL
      end

      def subject_via_plus_real_filesystem_plus_listener_ * a

        a.push :filesystem, the_real_filesystem_

        _FS_NORMALIZATIONS listener_, a
      end

      def subject_via_plus_listener_ * a

        _FS_NORMALIZATIONS listener_, a
      end

      def _FS_NORMALIZATIONS p, a

        _cls = subject_

        _x = _cls.call_via_iambic a, & p

        _x  # hi. #todo
      end

      define_method :the_real_filesystem_, ( Lazy_.call do
        Home_.services.filesystem
      end )
    # -

    # ==
    # ==
  end
end
