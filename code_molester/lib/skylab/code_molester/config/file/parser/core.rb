module Skylab::CodeMolester

  module Config

    module File

      module Parser

    # the actual mechanics of parsing the file is of course handled by
    # treetop. this module exists, then, only to manage how and whether
    # we cache the generated tree to disk and then loading any such
    # cached tree.

    y = nil  # yielder (internal)

    -> do  # `instance`

      # no matter what we will never be changing dynamically the grammar for
      # config files at runtime, nor will we (from this node and below) need
      # to support multiple syntaxes for config files, nor will there be any
      # load-time nonsense of dynamic enabling of grammar features. hence we
      # can do the below to the extent that all that holds. note the grammar
      # certainly changes over time during development, however. to this end
      # we maintain a semver.org-inspired grammar versioning scheme which is
      # used for uniquely representing the state of the grammar. the version
      # is incremented manually whenever there's a commit to *master* branch
      # that changes the grammar. NOTE all branches that are not master that
      # are making changes to the grammar must affix some identifying string
      # to the end of the version string (in VERSION). this scheme should be
      # considered from the perspectives of both developers checking out and
      # running different branches, and (perhaps most importantly of all) an
      # end-user (imgine again a developer) upgrading to a gem version where
      # the grammar changes. clearing a cache would thus never be necessary.

      # These kind of things are candidates to be pushed up into
      #  but should not be abstracted out of this
      # here until it feels stable.

      parent_module = Config_

      const = :FileParser  # treetop appends the 'Parser' for us.

      parser = nil  # (this on the other hand might be stupid - let's find out)

      parser_class = nil  # a function, mind you!
      define_singleton_method :instance do
        parser ||= parser_class[].new
      end

      debug = nil  # there is a proper setter for this at the end of this file

      debug = load_parser_class = nil
      parser_class = -> do
        if parent_module.const_defined? const, false
          debug and y << "constant existed! #{ const }"
          parent_module.const_get const, false
        else
          load_parser_class[]
        end
      end

        # both the the input path (the hand-written .tt file)
        # *and* the output path (the generated parser class)
        # will be derived from the above.

      cache_path = LIB_.existent_cache_dir
      compile_parser = nil
      fs = ::File

      load_parser_class = -> do

        path = ::File.join cache_path, Path_part__[]

        if fs.exist? path
          debug and y << "using cached parser - #{ path }"
        else
          compile_parser[ path ] or break  # (result is num bytes)
        end

        Home_::Library_.touch :Treetop  # load it late, close to where it is used

        load path

        parent_module.const_defined? const, false or fail "we expected but #{
          }did not see #{ parent_module }::#{ const } in #{ path }"

        parent_module.const_get const, false
      end

      mkdir_p = nil
      compile_parser = -> path do

        i_pn = Home_.dir_pathname.join( Path_part__[] ).  # hack around
          dirname.join( 'grammar.treetop' )                  #   'version-'
        cmp = Home_::Library_::Treetop::Compiler::GrammarCompiler.new

        ovr = fs.exist? path  # even if we never overwrite we don't know that here.

        if debug
          y << "#{ ovr ? 'overwriting existing' : 'creating new' } #{
            }generated treetop grammar parser class file - #{ path }"
        end

        dirname = ::File.dirname path
        if ! fs.exist? dirname
          mkdir_p[ dirname ]  # result is an array of the paths created
        end

        d = cmp.compile i_pn.to_s, path
        if debug
          y << "#{ ovr ? 'overwrote.' : 'created.' } (#{ d } bytes)"
        end
        d
      end

      num_occurences = nil

      mkdir_p = -> dirname do

        # the number of dirs you have to create should not exceed the
        # number of dirs present in `path_part`

        if ! fs.exist? cache_path
          self._COVER_ME
        end

        relpath = ::Pathname.new( dirname ).relative_path_from(
          ::Pathname.new cache_path
        ).to_path

        a = num_occurences[ relpath, ::File::SEPARATOR ]

        b = num_occurences[ Path_part__[], ::File::SEPARATOR ]

        ( a < b ) or fail "sanity - #{ a } dirs to create for #{ b - 1 }"

        LIB_.system.filesystem.file_utils_controller.new_via do | msg |

          debug and y << msg

        end.mkdir_p dirname
      end

      num_occurences = -> str, substr do
        i = j = 0
        f = -> { x = str.index( substr, i ) and ( i = x + 1 and j += 1 ) }
        nil while f[]
        j
      end

      y = -> do
        stderr = LIB_.system.IO.some_stderr_IO
        ::Enumerator::Yielder.new { |msg| stderr.puts "cm: #{ msg }" }
      end.call

      define_singleton_method :do_debug= do |x| debug = x end
    end.call

    -> do  # kinda hacky to do this here but we want it self-contained ..
      env_var = 'SKYLAB_CM_DEBUG'
      val = ::ENV[ env_var ]
      if val && EMPTY_S_ != val
        y << "#{ env_var }=#{ val.inspect }"
        self.do_debug = true
      end
    end.call

        Path_part__ = Callback_.memoize do
          head_pn = Parser_.dir_pathname
          version_s = head_pn.join( 'VERSION' ).read
          version_s.chomp!
          _full_pn = head_pn.join "version-#{ version_s }#{ Autoloader_::EXTNAME }"
          _full_pn.relative_path_from( Home_.dir_pathname ).to_path
        end

        Parser_ = self

      end
    end
  end
end
