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
    # ## comparison to "tree walk"
    #
    # this is expected to have the same result as the [#sy-176] "walk"
    # performer, but the algorithm is entirely different. whereas that
    # one starts from the argument path and works progressively upwards,
    # querying the filesystem for each successive parent directory, this
    # hits the filesystem only once (to make the "big tree") and then
    # starts at the common root between argument and tree and works
    # downwards from there.
    #
    # ## symlinks
    #
    # because of how we use symlinks during development (and how they may
    # be used generally), we need to normalize-away the use of symlinks,
    # otherwise the argument path against the filesystem sub-tree won't
    # have a partial head match to the adequate length and the algorithm
    # won't work. if both are certainly symlinks it would be OK, but meh.

    def initialize head, entry, middle, mod

      @_cache = {}
      @_first = true

      if ::File.lstat( head ).symlink?
        symlink_used = true
        orig_path = head
        head = ::File.readlink head
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

    def ___lookup normpath

      # insane - .. insane.

      _local_path = normpath[ @assets_dir.length + 1 .. -1 ]
      _x_a = _local_path.split ::File::SEPARATOR

      x = Autoloader_.const_reduce(
        :const_path, _x_a,
        :from_module, @from_module,
        :assume_is_defined,
        :final_path_to_load, normpath,
      )
      x or self._COVER_ME
      x
    end
  end
end
