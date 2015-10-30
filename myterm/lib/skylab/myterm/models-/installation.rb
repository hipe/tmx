module Skylab::MyTerm

  module Models_::Installation

    class Silo_Daemon

      # a wrapper for system-specific things.
      # this is an earmark for future efforts at portability.

      def initialize _k, _mod
      end

      def appearance_delta_path
        @___AD_path ||= ::File.join _data_path, 'myterm.json'
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

      def filesystem
        ::File
      end

      def _data_path
        @__data_path ||= ::File.join( ::ENV.fetch( 'HOME' ), '.myterm' )
      end
    end
  end
end
