module Skylab::Zerk

  class Models::GemNameElements < SimpleModel_

    # ==

    class Via_AlreadyLoaded < MonadicMagneticAndModel_

      def initialize ss_mod

        path = ss_mod.dir_path
        gem_path = ::File.expand_path '../../..', path
        _basename = ::File.basename gem_path

        @entry_string = Tools[]::
          Non_head_sements_via_gem_filessytem_entry___[ _basename ]

        @const_head_path = ss_mod.name.split( Common_::CONST_SEPARATOR ).map( & :intern )

        @gem_path = gem_path
        freeze
      end

      attr_reader(
        :const_head_path,
        :entry_string,
        :gem_path,
      )

      def exe_prefix
        # (normally this comes from the [tmx] "installation" instance)
        ASSUMED_EXE_PREFIX___
      end

      ASSUMED_EXE_PREFIX___ = 'tmx-'.freeze
    end

    # -

      def dup_by
        otr = dup
        yield otr
        otr.freeze
      end

      attr_accessor(
        :const_head_path,  # e.g [:SeaLab, :MySidesystem]
        :exe_prefix,       # always "tmx-" in this universe
        :entry_string,     # e.g "my_sidesystem"
        :gem_name,         # e.g "sea_lab-my_sidesystem"
        :gem_path,         # e.g "/Users/haxor/.gem/ruby/2.2.3/gems/sea_lab-my_sidesystem-0.0.0.pre.bleeding"
      )
    # -
    # ==

    Tools = Lazy_.call do

      # EGADS: it would be good to use whatever Gem does instead

      module GEM_NAME_TOOLS____

        piece = '[a-z][a-z0-9]+'
        segment = "#{ piece }(?:_#{ piece })*"
        major_number = '[0-9]+'
        freeform = '[a-z0-9][a-z0-9_]*'  # a guess

        rx = /\A
          (?<gem_name>
            #{ segment }
            (?: -
              (?<non_head_segments> #{ segment } (?: - #{ segment })* )
            )?
          )
          -
          (?<version> #{ major_number } (?: \. #{ freeform } )* )
        \z/x

        Gem_name_via_installed_gem_filesystem_entry = -> entry do
          rx.match( entry )[ :gem_name ]
        end

        Non_head_sements_via_gem_filessytem_entry___ = -> entry do
          rx.match( entry )[ :non_head_segments ]
        end

        define_method(
          :regexp_source_for_installed_gem_filesystem_entry_extended,
        ( Lazy_.call do
          rx.source[ 2 ... -2 ].strip
        end ) )

        self
      end
    end

    # ==
  end
end
# #history: moved to [ze] from [tmx] and reformatted/repurposed all
