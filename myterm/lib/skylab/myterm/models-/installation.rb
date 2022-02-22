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

      def volatile_image_path
        Volatile_image_path___[]
      end

      # -- The below attributes are undergirded by knownness so that if
      # the property is set to false-ish it stays set to that false-ish even
      # over the below lazy initialization of default values. this way, to
      # set one or both of them to false-ish could act as an assertion that
      # they are not used (for example from a test).

      def fonts_dir= x
        @_fonts_dir_knownness = KK__[ x ] ; x
      end

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

      def fonts_dir
        ( @_fonts_dir_knownness ||= _determine_fonts_dir_knownness ).value
      end

      def _determine_fonts_dir_knownness
        fail "needs visual testing on original platform (OS X). See comment"
        # One thing is almost certain: it's not appropriate for this to run its
        # tests against the "real" system fonts directory (very probably).
        # Another thing is, we don't know whether we want to try to broaden
        # this project to be multi-OS; and if so, we don't know which terminal
        # application(s) to target; and also, doing so would probably lead to
        # a radical re-architecting of this all (for example, something like
        # dependency injection to handle which terminal application we're
        # targeting (a "terminal adapter") and, which OS we're on probably
        # handled by something like a "fonts adapter" (because the way
        # "the fonts directory" works on Ubuntu is fundamentally different
        # than on OS X.))
        #
        # Suffice it to say, all of this is far out of scope for the current
        # commit, which involves simply trying to get all the tests passing
        # on Ubuntu that used to pass on OS X.
        #
        # (For one thing, we would have to be able to reliably test that
        # this works on all the targeted OS's)
        #
        return KK__[ FONTS_DIR___ ]
      end

      def filesystem
        ( @filesystem_knownness ||= KK__[ Home_.lib_.system.filesystem ] ).value
      end

      def system_conduit
        ( @system_conduit_knownness ||= KK__[ Home_.lib_.open3 ] ).value
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

      KK__ = Common_::KnownKnown
    end
  end
end
# #history-B.1: target Ubuntu not OS X
# #tombstone: persistence-related
