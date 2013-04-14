module Skylab::CodeMolester

  module Config
    Config = self  # stowaway - hiccuping this constant gives us the best
    # of multiple worlds - it is visible from inside the generated treetop
    # parser symbol actions, we don't need a very deep scope tree there,
    # and it will then transparently autoload lazily the desired node classes.
  end

  module Config::File::Parser

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
      # ::Skylab::TreetopTools, but should not be abstracted out of this
      # here until it feels stable.

      parent_module = Config

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

      path_part = "config/file/parser/version-#{
        ::File.read( "#{ __dir__ }/parser/VERSION" ).chomp
      }.rb"

        # both the the input path (the hand-written .tt file)
        # *and* the output path (the generated parser class)
        # will be derived from the above.

      compile_parser = nil
      load_parser_class = -> do
        o_pn = CodeMolester::Cache.pathname.join path_part
        if o_pn.exist?
          debug and y << "using cached parser - #{ o_pn }"
        else
          compile_parser[ o_pn ] or break  # (result is num bytes)
        end
        Services.const_get :Treetop, false  # we load that shit late
        load o_pn.to_s
        parent_module.const_defined? const, false or fail "we expected but #{
          }did not see #{ parent_module }::#{ const } in #{ o_pn }"
        parent_module.const_get const, false
      end

      mkdir_p = nil
      compile_parser = -> o_pn do

        i_pn = CodeMolester.dir_pathname.join( path_part ).  # hack around
          dirname.join( 'grammar.treetop' )                  #   'version-'
        cmp = Services::Treetop::Compiler::GrammarCompiler.new
        ovr = o_pn.exist?  # even if we never overwrite we don't know that here.
        if debug
          y << "#{ ovr ? 'overwriting existing' : 'creating new' } #{
            }generated treetop grammar parser class file - #{ o_pn }"
        end
        o_pn.dirname.tap do |d_pn|
          if ! d_pn.exist?
            mkdir_p[ d_pn ]  # result is an array of the paths created
          end
        end
        bts = cmp.compile i_pn.to_s, o_pn.to_s
        debug and y << "#{ ovr ? 'overwrote.' : 'created.' } (#{ bts } bytes)"
        bts
      end

      num_occurences = nil
      mkdir_p = -> d_pn do
        # the number of dirs you have to create should not exceed the
        # number of dirs present in `path_part`
        CodeMolester::Cache.pathname.exist? or fail "sanity"
        relpath = d_pn.relative_path_from CodeMolester::Cache.pathname
        a = num_occurences[ relpath.to_s, '/' ]
        b = num_occurences[ path_part, '/' ]
        ( a < b ) or fail "sanity - #{ a } dirs to create for #{ b - 1 }"
        Headless::IO::FU.new( -> msg do
          debug and y << msg
        end ).mkdir_p d_pn.to_s
      end

      num_occurences = -> str, substr do
        i = j = 0
        f = -> { x = str.index( substr, i ) and ( i = x + 1 and j += 1 ) }
        nil while f[]
        j
      end

      y = -> do
        stderr = $stderr
        ::Enumerator::Yielder.new { |msg| stderr.puts "cm: #{ msg }" }
      end.call

      define_singleton_method :do_debug= do |x| debug = x end
    end.call

    -> do  # kinda hacky to do this here but we want it self-contained ..
      env_var = 'SKYLAB_CM_DEBUG'
      val = ::ENV[ env_var ]
      if val
        y << "#{ env_var }=#{ val.inspect }"
        self.do_debug = true
      end
    end.call
  end
end
