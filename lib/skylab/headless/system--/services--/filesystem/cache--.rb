module Skylab::Headless

  module System__

    class Services__::Filesystem

      module Cache__

    # `cache_pathname_proc_via_module` -
    #
    # given a module Foo that responds to `cache_pathname`
    # (you must use this name (for now), for any parent module whose cache
    # dir pathname you want to be inherited by nested modules), and given
    # nested module Foo::Bar, if you call e.g:
    #
    #     Subject_[].cache_pathname_proc_via_module Foo::Bar
    #
    # the result is a function that will result in a memoized pathname that
    # represents the cache directory for you to use based on appending an
    # an inferred (or indicatded) filename to the parent node's pathname.
    #
    # the first this generated proc is called the directory will be created if
    # necessary, and it is required that the `cache_pathname` of the parent
    # module reflect a directory that exists. any such created directory
    # will use the same mode (permission set) as this parent directory.
    #
    # it is expected to be used something like this:
    #
    #     module Foo
    #       def self.cache_pathname
    #         @pn
    #       end
    #       @pn = ::Pathname.new '/var/xkcd/foo'
    #     end
    #
    #     module Foo::BarBaz
    #       define_singleton_method :cache_pathname, &
    #         Subject_[].cache_pathname_proc_via_module( self )
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
    #     `cache_pathname` is called for that module, hence do not expect
    #     the directory to exist if you never called `cache_pathname` for
    #     that module.
    #
    #   + the fact that it is memoized means that this check for the
    #     directory's existence will only happen exactly once during the
    #     runtime hence if you or something else removes the directory or
    #     changes its permissions during runtime, you are on your own to
    #     re-create the directory as necessary.
    #
    # Some features / behavior details:
    #
    #   + the filename ("foo-bar" in the above example) is of course inferred
    #     from the const name ("FooBar" in the example above. if you want a
    #     different filaname you can use the `abbrev` iambic option:
    #
    #    p = Subject_[].cache_pathname_proc_via_module self,
    #      :abbrev, 'some-other-filename'
    #
    #    p[]  # => #<Pathname:/var/xkcd/foo-some-other-filename>
    #
    #   + when searching upwards for a parent module that responds to
    #     `cache_pathname`, the search will hop over intermediate modules
    #     that do not do so; so you can design your module graph to contain
    #     as many modules as you find taxonomically useful, and not be held
    #     to making intermediate directories in your cache tree for modules
    #     that will not need their own cache directories.
    #
    #     module Foo
    #       define_singleton_method :cache_pathname, -> do
    #         _PN = ::Pathname.new( ::Dir.tmpdir ).join( 'my-app' )
    #         -> do
    #           _PN
    #         end
    #       end.call
    #
    #       module Bar
    #         module Baz
    #           define_singleton_method :cache_pathname, &
    #             Subject_[].cache_pathname_proc_via_module( self )
    #         end
    #       end
    #     end
    #
    #     Foo.cache_pathname            # => #<Pathname:/var/xkcd/my-app>
    #     Foo::Bar.cache_pathname       # raises ::NoMethodError
    #     Foo::Bar::Baz.cache_pathname  # => #<Pathname:/var/xkcd/my-app/baz>
    #
    # happy hacking!

        class << self

          def cache_pathname_proc_via_module mod, * x_a
            x_a.push :mod, mod
            Actor__.via_iambic x_a
          end
        end

        class Actor__

          Callback_::Actor.call self, :properties,
            :mod,
            :abbrev

          Headless_._lib.event_lib.selective_builder_sender_receiver self

          def initialize
            @abbrev = nil
            super
          end

          def execute
            ok = resolve_name_parts
            ok and build_proc
          end

        private

          def resolve_name_parts
            @const_a = @mod.name.split CONST_SEP_
            if 1 == @const_a.length
              when_too_few_name_parts
            else
              PROCEDE_
            end
          end

          def when_too_few_name_parts
            _ev = build_not_OK_event_with :toplevel_module,
                :mod, @mod, :error_category, :argument_error do |y, o|

              y << "this enhancement is for nested modules only (for now), #{
               } can't operate on toplevel module - #{ o.mod }"

            end
            finish_with_error_event _ev
          end

          def build_proc
            p = -> do
              _PN = build_pathname
              p = -> { _PN }
              _PN
            end
            -> do
              p[]
            end
          end

          def build_pathname
            ok = resolve_parent_pathname
            ok &&= resolve_filename
            ok && via_everything_build_existant_pathname
          end

          def resolve_parent_pathname
            ok = resolve_parent_cache_pathname_proprietor
            ok && via_parent_cache_pathname_proprietor_resolve_parent_pathname
          end

          def resolve_parent_cache_pathname_proprietor
            len = @const_a.length - 1
            mod_a = ::Array.new len
            cls = ::Object
            len.times do |d|
              cls = cls.const_get @const_a.fetch d
              mod_a[ d ] = cls
            end
            d = len
            while d.nonzero?
              d -= 1
              mod = mod_a.fetch d
              if mod.respond_to? :cache_pathname
                found = mod
                break
              end
            end
            if found
              @parent_cache_pathname_proprietor = found
              PROCEDE_
            else
              @mod_a = mod_a
              when_parent_not_found
            end
          end

          def when_parent_not_found
            _ev = build_not_OK_event_with :parent_cache_pathname_proprietor_not_found,
                :mod, @mod, :mod_a, @mod_a do |y, o|

              y << "none of the #{ o.mod_a.length } parent module(s) #{
                }responded to `cache_pathname` among #{ o.mod_a.last.name }"
            end
            finish_with_error_event _ev
          end

          def via_parent_cache_pathname_proprietor_resolve_parent_pathname
            @parent_pn = @parent_cache_pathname_proprietor.cache_pathname
            @parent_pn && PROCEDE_
          end

          def resolve_filename
            if @abbrev
              @filename = @abbrev
            else
              @filename = Callback_::Name.lib.pathify @const_a.last
            end
            via_filename_validate
          end

          def via_filename_validate
            if FILENAME_RX__ =~ @filename
              PROCEDE_
            else
              when_bad_filename
            end
          end

          def when_bad_filename
            _ev = build_not_OK_event_with(
              :filename_contains_invalid_characters, :filename, @filename,
              :error_category, :argument_error )
            finish_with_error_event _ev
          end

          def via_everything_build_existant_pathname  # :+[#022]
            pn = @parent_pn.join @filename
            if ! pn.exist?
              _mode = @parent_pn.stat.mode
              ::Dir.mkdir pn.to_path, _mode
            end
            pn
          end

          def finish_with_error_event ev
            send_error ev
            UNABLE_
          end

          def send_error ev
            raise ev.to_exception
          end

          FILENAME_RX__ = /\A[-_a-z0-9]+\z/i

        end
      end
    end
  end
end
