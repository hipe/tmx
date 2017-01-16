module Skylab::TMX

  class Models_::Installation < SimpleModel_

    # NOTE "installation" is a confusing name only at first: it does not
    # involve the act of installing anything. we mean it in the sense of
    # *your* installation of tmx on *your* system at this moment.

    # the "installation" is the first step towards reifying a tmx instance:
    # it holds basic configuration-like parameters and brings to life the
    # rest of the graph from that. see [#002] "tmx theory" for more.

    # see [#ze-030] "unified language" (under "sidesystems") for what
    # "gem name" means and related..

    attr_accessor(
      :participating_gem_const_head_path,
      :participating_gem_prefix,
      :participating_exe_prefix,
      :single_gems_dir,
    )

    def to_reflective_sidesystem_stream__

      self._NOT_USED__was_once__

      # 2x [sli] both times probably not covered:
      # 1x to make the sidesystem dependencies graph
      # 1x a not covered one-off for symlinking gems to a dev dir

      cls = Home_::Models_::Node::Reflective

      to_sidesystem_load_ticket_stream.map_by do | lt |
        cls.via_load_ticket lt
      end
    end

    def to_sidesystem_manifest_stream
      Home_::Magnetics_::ManifestStream_via_Installation[ self ]
    end

    def to_sidesystem_load_ticket_stream

      # if you would want the same results as what we see in the `map`
      # operation, see discussion at [#007.B] (inline)

      name_elements_for = nil

      main = -> path do

        # you actually do *not* want `path_normalizer_` here - it can
        # strip from the directory path gem-related information we need

        _ne = name_elements_for[ path ]
        Models_::LoadTicket.new _ne
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

    def load_ticket_via_normal_symbol_softly sym  # 1x here

      _entry = sym.id2name  # gem name segments (like normal symbols) use underscores

      _head_entry = @participating_gem_prefix[ 0...-1 ]  # "sea_lab" not "sea_lab-"

      gem_name = ::File.join _head_entry, _entry  # "skylab/derk_terst

      _yes = ::Gem.try_activate gem_name
      if _yes
        _lt = load_ticket_via_gem_name gem_name
        _lt
      end
    end

    def load_ticket_via_gem_name gem_require_path

      gem_name = gem_require_path.gsub ::File::SEPARATOR, DASH_

      _tailerer = Basic_[]::String::Tailerer_via_separator[ EMPTY_S_ ]
      _tailer = _tailerer[ @participating_gem_prefix ]
      _tail = _tailer[ gem_name ]

      _gne = Models_::GemNameElements.define do |ne|
        ne.entry_string = _tail
        ne.gem_name = gem_name
        ne.gem_path = :_ALREADY_LOADED_tmx_
        ne.const_head_path = @participating_gem_const_head_path
        ne.exe_prefix = @participating_exe_prefix
      end

      Models_::LoadTicket.new _gne
    end

    # our coupling to the gem API (and beyond) is both tight and
    # ephemeral, so we try to hide all of that here.

    Name_elementser__ = -> path, inst do

      exe_pfx = inst.participating_exe_prefix
      gem_prefix = inst.participating_gem_prefix
      const_head_path = inst.participating_gem_const_head_path

      # assume that the first path is like all the others in this respect,
      # so cache some details from it so that we don't recalculate the
      # same thing over and over

      stem_via_range = gem_prefix.length .. -1
      basename_via_range = path.length - ::File.basename( path ).length .. -1

      gem_name_via_entry = Models_::GemNameElements::Tools[]::
        Gem_name_via_installed_gem_filesystem_entry

      proto = Models_::GemNameElements.define do |ne|
        ne.const_head_path = const_head_path
        ne.exe_prefix = exe_pfx
      end

      -> path_ do

        gemname = gem_name_via_entry[ path_[ basename_via_range ] ]

        proto.dup_by do |ne|
          ne.entry_string = gemname[ stem_via_range ]
          ne.gem_name = gemname
          ne.gem_path = path_
        end
      end
    end

    # ==

  end
end
# #tombstone-C: got rid of name fix hack
# :#tombstone: again
# :#tombstone: was rewritten
