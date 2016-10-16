module Skylab::TanMan::TestSupport

  class Proximity_Index_

    # given both
    #
    #   • a filesystem tree of "assets" (files) defined as being the
    #     sub-tree of files with a certain given fixed string entry name,
    #     under a certain given "assets directory" path, and
    #
    #   • an arbitrary argument path on the same filesystem,
    #
    # find the "closest" asset for the argument path using the [ba] tree
    # "winnow" algorithm. imagine that the "arg" file below is the argument
    # path and we want to find the "closest" asset file:
    #
    #     /body/head/neck/arg
    #     /body/head/asset
    #     /body/torso/asset
    #     /body/asset
    #
    # there is no asset file in the "neck" directory, but if there
    # were that would be the closest. since one is found in the parent
    # directory ("head" in the example), that is closest. the asset in
    # "body" is therefor never reached. because the "torso" directory
    # is not one of the parent directories of the argument directory,
    # that asset is never reached either.
    #
    #
    #
    # ## algorithm (and comparison to "tree walk")
    #
    # this is expected to have the same result as the [#sy-176] "walk"
    # performer, but our algorithm is entirely upside-down to that one.
    # whereas that one starts from the argument path and works progressively
    # upwards, querying the filesystem for each successive parent directory
    # ("do you have this path? no? well do you have this path?.."); this
    # one hits the filesystem only once (to make the "big tree") and walks
    # downward from the root of this tree using each component from the
    # argument path ("under the current node, do you have this component?
    # yes? [changed current node] under the current node do you have [..]?"),
    # noting the last "current node" that had the asset.
    #
    # this "big tree" (whose every leaf is every asset file) is meant to
    # be memoized so that to find the right asset for any given path the
    # filesystem is only ever hit once for the lifetime of the process.
    #
    # it is expected that this approach scales better to many requests
    # both for the reason that it reduces the number of filesystem hits
    # and because for a tree (notwithstanding filesystem) to answer the
    # questions
    #
    #     do you have "/A/B/C/D"? no? well do you have
    #     do you have "/A/B/C"? no? well do you have
    #     do you have "/A/B"? yes? ok, thanks.
    #
    # the "hits" to resolve "A" then "B" the first two times are effectively
    # "wasted", whereas with our approach:
    #
    #     do you have "A"? yes? well
    #     do you have "B" (under that)? yes? well
    #     do you have "C" (under that)? no? ok, thanks.
    #
    # minimizes these "hits".
    #
    #
    #
    # ## symlinks
    #
    # sadly the above elegance falls apart in practice in cases where the
    # argument path is "really" under the "big tree", but symlinks are
    # present among the "big tree" path and/or argument path in an
    # asymmetrical way (that is, if one or the other uses them, or they both
    # use them for different paths from each other).
    #
    # for now, rather than check if every single parent directory in both the
    # "big tree" path and every single argument path is a symlink, we
    # heuristically normalize-out such cases based on how we use symlinks
    # in our devlopement. this makes the subject node "impure" (i.e not fit
    # for general use), but does not diminish its merit as proof of concept.

    def initialize head, entry, middle, mod

      @_cache = {}
      @_first = true

       # #heuristic:one - un-symlink the "sidesystem" directory

      if ::File.lstat( head ).symlink?
        symlink_used = true
        orig_path = head
        head = ::File.readlink head
      end

      # #heuristic:two - un-symlink the would be "top-of-the-universe" dir

      if head.include? ::File::SEPARATOR
        _ToU_dir = ::File.dirname head
        if ::File.lstat( _ToU_dir ).symlink?
          if ! symlink_used
            self._COVER_ME
          end
          _real_top_of_universe = ::File.readlink _ToU_dir
          head = ::File.join _real_top_of_universe, ::File.basename( head )
        end
      end

      assets_dir = ::File.join head, middle

      _list = ::Dir[ "#{ assets_dir }/**/#{ entry }" ]

      _tree = Home_.lib_.basic::Tree.via :paths, _list

      @assets_dir = assets_dir
      @entry = entry
      @from_module = mod
      @symlink_path = orig_path
      @symlink_used = symlink_used
      @tree = _tree
    end

    attr_reader(
      :assets_dir,
      :symlink_path,
      :symlink_used,
      :tree,
    )

    def nearest_such_class_to_path arg_abspath

      _normpath = ___target_normpath_via_arg_abspath arg_abspath
      __asset_via_normpath _normpath
    end

    def ___target_normpath_via_arg_abspath abs_path

      if @_first
        ___see_first_argument_path abs_path
      end

      if @_args_are_symlinks
        abs_path = ::File.readlink abs_path
      end

      st, node = @tree.winnow abs_path

      _ok = if st.unparsed_exists
        if node[ @entry ]
          true
        end
      else
        true
      end

      if _ok
        s_a = st.array_for_read[ 0 ... st.current_index ]
        s_a.push @entry
        s_a.join ::File::SEPARATOR
      else
        self._NONE
      end
    end

    def ___see_first_argument_path abs_path
      @_first = false
      if @symlink_used
        s = @symlink_path
        if s == abs_path[ 0, s.length ]
          self._COVER_ME_we_need_to_dereference_all_symlinks_PROBABLY_OK
          args_are_symlinks = true
        end
      end
      @_args_are_symlinks = args_are_symlinks ; nil
    end

    def __asset_via_normpath normpath

      @_cache.fetch normpath do
        x = ___lookup normpath
        @_cache[ normpath ] = x
        x
      end
    end

    def ___lookup client_path

      # we employ a strange convention whereby a file can be both a normal
      # asset file and an executable. (this is so we can "visual test" a
      # fixture grammar almost for free.) however, one cost of this is that
      # the autoloader cannot load files like this because they "look like"
      # directories. as such we have to do the loading here "by hand" with
      # logic that once lived in "const reduce" but has been simplified out
      # of it for now.

      _localizer = Home_::Path_lib_[]::Localizer[ @assets_dir ]
      _local_path = _localizer[ client_path ]
      _entries = _local_path.split ::File::SEPARATOR

      scn = Common_::Polymorphic_Stream.via_array _entries

      mod = @from_module
      begin
        slug = scn.gets_one
        is_last = scn.no_unparsed_exists
        const = Common_::Name.via_slug( slug ).as_const

        if is_last
          ::Kernel.load client_path
        end

        mod = mod.const_get const, false
      end until is_last

      mod
    end
  end
end
