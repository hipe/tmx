module Skylab::MyTerm

  module Models_::Installation

    class Silo_Daemon

      # a wrapper for system-specific things.
      # this is an earmark for future efforts at portability.

      def initialize _k, _mod
      end

      def any_existing_read_writable_IO

        filesystem.open _appearance_persistence_path, ::File::RDWR
      rescue ::Errno::ENOENT
      end

      def writable_IO * x_p

        fs = filesystem
        path = _appearance_persistence_path

        dirname = ::File.dirname path
        if ! fs.exist? dirname
          fs.mkdir_p dirname, & x_p
        end
        fs.open path, ::File::CREAT | ::File::WRONLY
      end

      def _appearance_persistence_path
        @___path ||= ::File.join _data_path, 'myterm.json'
      end

      def get_font_file_extensions
        %w( dfont otf ttc ttf )
      end

      def fonts_dir
        @___fonts_dir ||= '/System/Library/Fonts'.freeze
      end

      def get_volatile_image_path
        ::File.join _data_path, 'volatile-image.png'
      end

      def _data_path
        @__data_path ||= ::File.join( ::ENV.fetch( 'HOME' ), '.myterm' )
      end

      # -- the below two attributes are undergirded by knownness so that if
      # they are explicitly set to a false-ish, it is preserved even against
      # the below lazy initialization of default values. this preserves for
      # us the option of asserting (for example in a test) that the
      # particular conduit is not used, simply by setting it to false.

      def system_conduit= x
        @system_conduit_knownness = KK__[ x ] ; x
      end

      attr_writer(
        :filesystem_knownness,
        :system_conduit_knownness,
      )

      def filesystem
        ( @filesystem_knownness ||= KK__[ Home_.lib_.system.filesystem ] ).value_x
      end

      def system_conduit
        ( @system_conduit_knownness ||= KK__[ Home_.lib_.open3 ] ).value_x
      end

      KK__ = Callback_::Known_Known

      # --
    end
  end
end
