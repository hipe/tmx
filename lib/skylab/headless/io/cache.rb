module Skylab::Headless

  module IO::Cache

    # (we almost made an `FS` node under `IO` but held back for now..)

    # `build_cache_pathname_function_for` -
    #
    # given toplevel module ::Foo that responds to `cache_pathname`
    # (you must use this name (for now), for any parent module whose cache
    # dir pathname you want to be inherited by nested modules), and given
    # nested module ::Foo::Bar, if you call e.g:
    #
    #     IO::Cache.build_cache_pathname_function_for ::Foo::Bar
    #
    # , the result is a function that will result in a memoized pathname that
    # reprents a cache directory for you to use.
    #
    # the first time that function is called, the directory will be created if
    # necessary, and requires that the `cache_pathname` of the resolved parent
    # module represent a directory that exists. any such created directory
    # will use the same mode (permission set) as this parent directory.
    #
    # it is expected to be used something like this:
    #
    #     # assume `Foo.cache_pathname` resolves to a ::Pathname that
    #     # represents a writeable, existing directory path.
    #     # e.g.
    #     #     Foo.cache_pathname  # => #<Pathname:/var/xkcd/foo>
    #
    #     module Foo::BarBaz
    #       define_singleton_method :cache_pathname, &
    #         IO::Cache.build_cache_pathname_function_for( self )
    #     end
    #
    #     # now you have:
    #
    #     Foo::BarBaz.cache_pathname  # => #<Pathname:/var/xkcd/foo/bar-baz>
    #
    #     # which exists and has the same permissions as the parent diretory.
    #
    # Some gotchas so far:
    #
    #   + the directory is created (if necessary) *lazily* the first time
    # `cache_pathname` is called for that module, hence do not expect the
    # directory to exist if you never called `cache_pathname` for that module.
    #
    #   + the fact that it is memoized means that this check for the
    # directory's existence will only happen exactly once during the runtime
    # hence if you or something else removes the directory or changes its
    # permissions during runtime, this will not yet play nicely with that.
    #
    # Some features / behavior details:
    #
    #   + the filename ("foo-bar" in the example above) used for the
    # created cache directory is inferred from the const name fragment
    # ("FooBar" in the example above). If you want to use a different name,
    # you can use the `abbrev` option in an optional DSL-ish block:
    #
    #   f = IO::Cache.build_cache_pathname_function_for( self ) do
    #     abbrev 'some-other-filename'
    #   end
    #
    #   f[]  # => #<Pathname:/var/xkcd/foo-some-other-filename>
    #
    #   + when searching up for a parent module that responds to
    # `cache_pathname`, the search will hop over intermediate modules that
    # do not -- so you can design your module graph to contain as
    # many modules as you deem semantically necessary, and not be held to
    # making intermediate directories in you cache tree for modules that don't
    # need them.
    #
    #     module Foo
    #       -> do
    #         pn = ::Pathname.new( ::Dir.tmpdir ).join( 'my-app' )
    #         define_singleton_method :cache_pathname do pn end
    #       end.call
    #
    #       module Bar
    #         module Baz
    #           define_singleton_method :cache_pathname, &
    #             Headless::IO::Cache.build_cache_pathname_function_for( self )
    #         end
    #       end
    #     end
    #
    #     Foo.cache_pathname            # => #<Pathname:/var/xkcd/my-app>
    #     Foo::Bar.cache_pathname       # raises ::NoMethodError
    #     Foo::Bar::Baz.cache_pathname  # => #<Pathname:/var/xkcd/my-app/bar>
    #
    # happy hacking!

    -> do  # `self.build_cache_pathname_function_for`

      fn_rx = /\A[-_a-z0-9]+\z/i

      define_singleton_method :build_cache_pathname_function_for do |mod, &blk|
        filename = nil
        if blk
          Shell_.new( -> x do
            if fn_rx =~ x
              filename = x
            else
              raise "filename contains invalid characters - #{ x }"
            end
          end ).instance_exec( & blk )
        end
        pathname_and_mode = -> do
          const_a = mod.name.split '::'
          1 == const_a.length and raise "this module enhancement is for #{
            } nested modules only (for now)"
          mod_a = [ ]
          const_a.reduce ::Object do |m, c|
            m_ = m.const_get c, false
            mod_a << m_
            m_
          end
          begin
            last_base = const_a.pop
            last_base or fail "sanity - none of these parent modules #{
              }responded to `cache_pathname` - #{ mod_a[ 0 .. -2 ] }"
            idx = const_a.length - 1
            mod = mod_a.fetch idx
          end while ! mod.respond_to? :cache_pathname
          filename ||= Autoloader::FUN::Pathify[ last_base ]
          [ mod.cache_pathname.join( filename ), mod.cache_pathname.stat.mode ]
        end

        cache_pn = nil
        -> do  # the cache path function
          cache_pn ||= begin
            pn, mode = pathname_and_mode[ ]
            if ! pn.exist?
              ::Dir.mkdir pn.to_s, mode
            end
            pn
          end
          cache_pn
        end
      end
    end.call

    class Shell_

      def abbrev x
        @abbrev[ x ]
        nil
      end

      def initialize abbrev
        @abbrev = abbrev
      end
    end
  end
end
