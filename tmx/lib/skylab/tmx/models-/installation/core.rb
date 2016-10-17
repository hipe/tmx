module Skylab::TMX

  class Models_::Installation

    # NOTE "installation" is a confusing name only at first: it does not
    # involve the act of installing anything. we mean it in the sense of
    # *your* installation of tmx on *your* system at this moment.

    # the "installation" is the first step towards being a tmx instance: it
    # holds basic configuration-like parameters and brings to life the rest
    # of the graph from that. see [#002] "tmx theory" for more.

    attr_accessor(
      :participating_gem_const_path_head,
      :participating_gem_prefix,
      :participating_exe_prefix,
      :single_gems_dir,
    )

    def done
      freeze  # or not..
    end

    def lookup_reflective_sidesystem__ stem

      # assume that `stem` is isomorphic with a sidesystem in the
      # installation.

      gem_name = "#{ @participating_gem_prefix }#{ stem }"

      gne = Gem_Name_Elements_.new

      gne.stem = stem
      gne.gem_name = gem_name
      gne.const_a = @participating_gem_const_path_head
      gne.exe_prefix = @participating_exe_prefix

      _sp = Gem::Specification.find_by_name gem_name, '>= 0.pre'
      _entry = "#{ gem_name }-#{ _sp.version }"
      gne.gem_path = ::File.join @single_gems_dir, _entry

      Load_Ticket_.new gne
    end

    def to_reflective_sidesystem_stream__

      cls = Home_::Models_::Sidesystem::Reflective

      to_sidesystem_load_ticket_stream.map_by do | lt |
        cls.via_load_ticket lt
      end
    end

    def to_sidesystem_manifest_stream

      Here_::Build_manifest_stream___[ self ]
    end

    def to_sidesystem_load_ticket_stream

      _wow = __build_filesystem_listing_of_all_participating_gems

      p = -> path do

        name_elements_for = Name_elementser___[ path, self ]

        p = -> path_ do

          Load_Ticket_.new name_elements_for[ path_ ]
        end

        p[ path ]
      end

      Common_::Stream.via_nonsparse_array _wow do | path |
        p[ path ]
      end
    end

    def __build_filesystem_listing_of_all_participating_gems

      ::Dir[ ::File.join( @single_gems_dir, "#{ @participating_gem_prefix }*" ) ]
    end

    # our coupling to the gem API (and beyond) is both tight and
    # ephemeral, so we try to hide all of that here.

    Name_elementser___ = -> path, inst do

      exe_pfx = inst.participating_exe_prefix
      gem_prefix = inst.participating_gem_prefix
      const_a = inst.participating_gem_const_path_head


      # assume that the first path is like all the others in this respect,
      # so cache some details from it so that we don't recalculate the
      # same thing over and over

      stem_via_range = gem_prefix.length .. -1
      basename_via_range = path.length - ::File.basename( path ).length .. -1

      gem_name_via_entry = Gem_name_tools_[].Gem_name_via_entry

      proto = Gem_Name_Elements_.new nil, nil, nil, const_a, exe_pfx

      -> path_ do

        gemname = gem_name_via_entry[ path_[ basename_via_range ] ]

        gne = proto.dup
        gne.stem = gemname[ stem_via_range ]
        gne.gem_name = gemname
        gne.gem_path = path_
        gne
      end
    end

    Gem_Name_Elements_ = ::Struct.new(
      :stem, :gem_name, :gem_path, :const_a, :exe_prefix )

    class Load_Ticket_

      attr_reader(
        :const_path_array_guess,
        :gem_name_elements,
        :require_path,
      )

      def initialize gne  # Gem_Name_Elements_

        @require_path = gne.gem_name.gsub DASH_, ::File::SEPARATOR

        cpa = gne.const_a.dup

        gne.stem.split( DASH_ ).each do | segment |
          cpa.push segment.gsub( WORD_SEP_RX___ ){ $1.upcase }.intern
        end

        @const_path_array_guess = cpa

        @gem_name_elements = gne

      end

      WORD_SEP_RX___ = /(?:(?<=^|\d)|_)([a-z])/

      def require_sidesystem_module
        @____sidesys_mod ||= __induce_sidesystem_module
      end

      def __induce_sidesystem_module

        require @require_path

        Autoloader_.const_reduce @const_path_array_guess, ::Object
      end

      def path_to_gem
        @gem_name_elements.gem_path
      end

      def stem
        @gem_name_elements.stem
      end
    end

    Gem_name_tools_ = Lazy_.call do

      # EGADS: it would be good to use whatever Gem does instead

      module GEM_NAME_TOOLS___

        user_word = '[a-z][a-z0-9_]*'
        major_number = '[0-9]+'
        freeform = '[a-z0-9][a-z0-9_]*'  # a guess

        rxs = "(?<gem_name> #{ user_word } (?: - #{ user_word } )* )
          - (?<version> #{ major_number } (?: \\. #{ freeform } )*  )"

        rx = /\A#{ rxs }\z/x

        p = -> entry do
          rx.match( entry )[ :gem_name ]
        end

        define_singleton_method :Gem_name_via_entry do
          p
        end

        define_singleton_method :RXS do
          rxs
        end

        self
      end
    end

    DASH_ = '-'
    Here_ = self
  end
end
# :#tombstone: again
# :#tombstone: was rewritten
