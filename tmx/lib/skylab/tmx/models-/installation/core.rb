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

    def lookup_reflective_sidesystem__ entry_string

      # assume that `stem` is isomorphic with a sidesystem in the
      # installation.

      gem_name = "#{ @participating_gem_prefix }#{ entry_string }"

      gne = GemNameElements_.new

      gne.entry_string = entry_string
      gne.gem_name = gem_name
      gne.const_head_path = @participating_gem_const_path_head
      gne.exe_prefix = @participating_exe_prefix

      _sp = Gem::Specification.find_by_name gem_name, '>= 0.pre'
      _entry = "#{ gem_name }-#{ _sp.version }"
      gne.gem_path = ::File.join @single_gems_dir, _entry

      LoadTicket_.new gne
    end

    def to_reflective_sidesystem_stream__

      # 2x [sli] both times probably not covered:
      # 1x to make the sidesystem dependencies graph
      # 1x a not covered one-off for symlinking gems to a dev dir

      cls = Home_::Models_::Node::Reflective

      to_sidesystem_load_ticket_stream.map_by do | lt |
        cls.via_load_ticket lt
      end
    end

    def to_sidesystem_manifest_stream

      Here_::ManifestStream_via_Installation___[ self ]
    end

    def to_sidesystem_load_ticket_stream

      # if you would want the same results as what we see in the `map`
      # operation, see discussion at [#007.B] (inline)

      name_elements_for = nil

      main = -> path do

        # you actually do *not* want `path_normalizer_` here - it can
        # strip from the directory path gem-related information we need

        _ne = name_elements_for[ path ]
        LoadTicket_.new _ne
      end

      p = -> path do

        name_elements_for = Name_elementser__[ path, self ]

        ( p = main )[ path ]
      end

      _big_list = __build_filesystem_listing_of_all_participating_gems

      Stream_.call _big_list do |path|
        p[ path ]
      end
    end

    def __build_filesystem_listing_of_all_participating_gems

      ::Dir[ ::File.join( @single_gems_dir, "#{ @participating_gem_prefix }*" ) ]
    end

    def load_ticket_via_gem_name gem_require_path

      gem_name = gem_require_path.gsub ::File::SEPARATOR, DASH_

      _tailerer = Basic_[]::String::Tailerer_via_separator[ EMPTY_S_ ]
      _tailer = _tailerer[ @participating_gem_prefix ]
      _tail = _tailer[ gem_name ]

      ne = GemNameElements_.new
      ne.entry_string = _tail
      ne.gem_name = gem_name
      ne.gem_path = :_ALREADY_LOADED_tmx_
      ne.const_head_path = @participating_gem_const_path_head
      ne.exe_prefix = @participating_exe_prefix

      LoadTicket_.new ne
    end

    # our coupling to the gem API (and beyond) is both tight and
    # ephemeral, so we try to hide all of that here.

    Name_elementser__ = -> path, inst do

      exe_pfx = inst.participating_exe_prefix
      gem_prefix = inst.participating_gem_prefix
      const_head_path = inst.participating_gem_const_path_head

      # assume that the first path is like all the others in this respect,
      # so cache some details from it so that we don't recalculate the
      # same thing over and over

      stem_via_range = gem_prefix.length .. -1
      basename_via_range = path.length - ::File.basename( path ).length .. -1

      gem_name_via_entry = Gem_name_tools_[].Gem_name_via_entry

      proto = GemNameElements_.new nil, nil, nil, const_head_path, exe_pfx

      -> path_ do

        gemname = gem_name_via_entry[ path_[ basename_via_range ] ]

        gne = proto.dup
        gne.entry_string = gemname[ stem_via_range ]
        gne.gem_name = gemname
        gne.gem_path = path_
        gne
      end
    end

    GemNameElements_ = ::Struct.new(
      :entry_string, :gem_name, :gem_path, :const_head_path, :exe_prefix )

    class LoadTicket_

      def initialize gne  # GemNameElements_

        @require_path = gne.gem_name.gsub DASH_, ::File::SEPARATOR

        const_path_guess = []

        gne.gem_name.split( DASH_ ).each do |segment|
          const_path_guess.push segment.gsub( WORD_SEP_RX___ ){ $1.upcase }.intern
        end

        gne.const_head_path.each_with_index do |sym, d|
          const_path_guess.fetch( d ) == sym && next
          self._NAME_SANITY
        end

        @const_path_array_guess = const_path_guess.freeze

        @gem_name_elements = gne
      end

      WORD_SEP_RX___ = %r((?:(?<=^|\d)|_)([a-z]))
      # also worked: %r(_?(?<![a-z])([a-z0-9]))
      # see #tombstone-C, was #wish [#co-067]

      def require_sidesystem_module
        @____sidesys_mod ||= __induce_sidesystem_module
      end

      def __induce_sidesystem_module

        require @require_path

        # we avoid using `const_reduce` (for name correction) unless we
        # need to (for no good reason).
        # this is near but not the same as [#br-083]

        mod = ::Object
        sym_a = const_path_array_guess
        ( sym_a.length - 1 ).times do |d|
          mod = mod.const_get sym_a.fetch d  # until it fails
        end

        const = sym_a.fetch( -1 )

        if mod.const_defined? const, false
          mod.const_get const, false
        else
          # (strange - probably a holdover from when we had old toplevel names)
          _ = Autoloader_.const_reduce [ const ], mod
          _
        end
      end

      def path_to_gem
        @gem_name_elements.gem_path
      end

      def intern
        @___as_intern ||= @gem_name_elements.entry_string.intern
      end

      def entry_string
        @gem_name_elements.entry_string
      end

      attr_reader(
        :const_path_array_guess,
        :gem_name_elements,
        :require_path,
      )

      def IS_LOAD_TICKET_tmx_  # temporary
        true
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

    Here_ = self
  end
end
# #tombstone-C: got rid of name fix hack
# :#tombstone: again
# :#tombstone: was rewritten
