module Skylab::MyTerm

  module Models_::Installation

    class Silo_Daemon

      # a wrapper for system-specific things.
      # this is an earmark for future efforts at portability.

      def initialize _k, _mod
      end

      def any_existing_read_writable_IO

        _filesystem.open _appearance_persistence_path, ::File::RDWR
      rescue ::Errno::ENOENT
      end

      def writable_IO * x_p

        fs = _filesystem
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

      def _filesystem
        @___FS ||= Home_.lib_.system.filesystem
      end

      alias_method :filesystem, :_filesystem  # localize the exposure
    end
  end
end
