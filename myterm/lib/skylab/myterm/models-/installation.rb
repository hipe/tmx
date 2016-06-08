module Skylab::MyTerm

  module Models_::Installation

    class Silo_Daemon

      # a wrapper for system-specific things.
      # this is an earmark for future efforts at portability.
      # decidedly not portable at present

      def initialize _k, _mod
      end

      def font_file_extensions
        Font_file_extensions___[]
      end

      def fonts_dir
        FONTS_DIR___
      end

      def volatile_image_path
        Volatile_image_path___[]
      end

      # -- the below two attributes are undergirded by knownness so that if
      # the property is set to false-ish it says set to that false-ish even
      # over the below lazy initialization of default values. this way, to
      # set one or both of them to false-ish could act as an assertion that
      # they are not used (for example from a test).

      def filesystem= x
        @filesystem_knownness = KK__[ x ] ; x
      end

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

      # --

      Data_path___ = Lazy_.call do
        ::File.join ::ENV.fetch( 'HOME' ), '.myterm'
      end

      Font_file_extensions___ = Lazy_.call do
        %w( dfont otf ttc ttf )
      end

      FONTS_DIR___ = '/System/Library/Fonts'

      Volatile_image_path___ = Lazy_.call do
        ::File.join Data_path___[], 'volatile-image.png'
      end

      # --

      KK__ = Common_::Known_Known
    end
  end
end
# #tombstone: persistence-related
