module Skylab::System

  module Filesystem

    class Cache

    # `cache_path_proc_via_module` -
    #
    # given a module Foo that responds to `cache_path`
    # (you must use this name (for now), for any parent module whose cache
    # dir path you want to be inherited by nested modules), and given
    # nested module Foo::Bar, if you call e.g:
    #
    #    Subject_[].cache_path_proc_via_module Foo::Bar
    #
    # the result is a function that will result in a memoized path that
    # represents the cache directory for you to use based on appending an
    # an inferred (or indicatded) filename to the parent node's path.
    #
    # the first this generated proc is called the directory will be created if
    # necessary, and it is required that the `cache_path` of the parent
    # module reflect a directory that exists. any such created directory
    # will use the same mode (permission set) as this parent directory.
    #
    # some top module will need to define `cache_path` for itself,
    # then a nested module can use the topic:
    #
    #     module Foo
    #
    #       def self.cache_path
    #         Tmpdir_[]
    #       end
    #
    #       module BarBaz
    #         _p = Home_.services.filesystem.cache.cache_path_proc_via_module self
    #         define_singleton_method :cache_path, _p
    #       end
    #     end
    #
    # the nested client module builds its `cache_path` isomoprhically:
    #
    #     Foo::BarBaz.cache_path  # => ::File.join( Tmpdir_[], 'bar-baz' )
    #
    # (the above directory also has the same permissons as the parent directory)
    #
    # Some gotchas so far:
    #
    #   - the directory is created (if necessary) *lazily* the first time
    #     `cache_path` is called for that module, hence do not expect
    #     the directory to exist if you never called `cache_path` for
    #     that module.
    #
    #   - the fact that it is memoized means that this check for the
    #     directory's existence will only happen exactly once during the
    #     runtime hence if you or something else removes the directory or
    #     changes its permissions during runtime, you are on your own to
    #     re-create the directory as necessary.

    # Some features / behavior details:
    #
    #   - the `abbrev` option
    #     the filename ("foo-bar" in the above example) is of course inferred
    #     from the const name ("Foo::BarBaz" in the example above).
    #     if you want a filename other than what is inferred, use `abbrev`:
    #
    #         module Foo2
    #           def self.cache_path
    #             Tmpdir_[]
    #           end
    #           Bar = ::Module.new
    #         end
    #
    #         _p = Home_.services.filesystem.cache.cache_path_proc_via_module(
    #           Foo2::Bar,
    #           :abbrev, 'some-other-filename',
    #         )
    #
    #         _p[]  # => ::File.join( Tmpdir_[], 'some-other-filename' )
    #
    #   - hopping modules
    #     when searching upwards for a parent module that responds to
    #     `cache_path`, the search will hop over intermediate modules
    #     that do not do so; so you can design your module graph to contain
    #     as many modules as you find taxonomically useful, and not be held
    #     to making intermediate directories in your cache tree. so
    #     not all intermediate modules need to have their own cache directories:
    #
    #         module Foo3
    #
    #           def self.cache_path
    #             Tmpdir_[]
    #           end
    #
    #           module Bar
    #             module Baz
    #               _p = Home_.services.filesystem.cache.cache_path_proc_via_module self
    #               define_singleton_method :cache_path, _p
    #             end
    #           end
    #         end
    #
    #     the (locally) topmost module knows its associated path:
    #
    #         Foo3.cache_path  # => Tmpdir_[]
    #
    #     but this intermediate module has no associated path:
    #
    #         Foo3::Bar.respond_to?( :cache_path )  # => false
    #
    #     but yet this here, innermost module SKIPS OVER the intermediate step:
    #
    #         Foo3::Bar::Baz.cache_path  # => ::File.join( Tmpdir_[], 'baz' )
    #
    # happy hacking!

      class << self

        def [] mod, * x_a
          _p = Home_.services.filesystem.cache.cache_path_proc_via_module mod, * x_a
          mod.define_singleton_method :cache_path, _p
          NIL
        end
      end  # >>

      def initialize fs
        @_filesystem = fs
      end

      def cache_path_proc_via_module mod, * x_a
        _cache_path_proc_via mod, x_a
      end

      def _cache_path_proc_via mod, x_a

        @_actor_curry ||= Actor___.curry_with(
          :filesystem, @_filesystem,
        )

        x_a.push :mod, mod

        @_actor_curry.call_via_iambic x_a
      end

      # ->

        class Actor___

          Attributes_actor_.call( self,
            :mod,
            :abbrev,
            :filesystem,
          )

          include Common_::Event::ReceiveAndSendMethods

          def initialize
            @abbrev = nil
          end

          def call_via_iambic x_a
            otr = dup
            otr.send :process_iambic_fully, x_a
            otr.execute
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
              ACHIEVED_
            end
          end

          def when_too_few_name_parts

            _ev = build_not_OK_event_with(
              :toplevel_module,
              :mod, @mod,
              :exception_class_by, -> { RuntimeError },
              :error_category, :argument_error

            ) do |y, o|

              y << "this enhancement is for nested modules only (for now), #{
               } can't operate on toplevel module - #{ o.mod }"
            end

            finish_with_error_event _ev
          end

          def build_proc
            p = -> do
              _PN = build_path
              p = -> { _PN }
              _PN
            end
            -> do
              p[]
            end
          end

          def build_path
            ok = resolve_parent_path
            ok &&= resolve_filename
            ok && via_everything_build_existant_path
          end

          def resolve_parent_path
            ok = resolve_parent_cache_path_proprietor
            ok && __via_parent_cache_path_proprietor_resolve_parent_path
          end

          def resolve_parent_cache_path_proprietor
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
              if mod.respond_to? :cache_path
                found = mod
                break
              end
            end
            if found
              @parent_cache_path_proprietor = found
              ACHIEVED_
            else
              @mod_a = mod_a
              when_parent_not_found
            end
          end

          def when_parent_not_found

            _ev = build_not_OK_event_with(
              :parent_cache_path_proprietor_not_found,
              :mod, @mod,
              :mod_a, @mod_a,
              :exception_class_by, -> { RuntimeError },

            ) do |y, o|

              y << "none of the #{ o.mod_a.length } parent module(s) #{
                }responded to `cache_path` among #{ o.mod_a.last.name }"
            end

            finish_with_error_event _ev
          end

          def __via_parent_cache_path_proprietor_resolve_parent_path

            path = @parent_cache_path_proprietor.cache_path
            if path
              @_parent_path = path
              ACHIEVED_
            else
              path
            end
          end

          def resolve_filename
            if @abbrev
              @filename = @abbrev
            else
              @filename = Common_::Name::Conversion_Functions::Pathify[
                @const_a.last ]
            end
            via_filename_validate
          end

          def via_filename_validate
            if FILENAME_RX__ =~ @filename
              ACHIEVED_
            else
              when_bad_filename
            end
          end

          def when_bad_filename

            _ev = build_not_OK_event_with(
              :filename_contains_invalid_characters,
              :filename, @filename,
              :exception_class_by, -> { RuntimeError },
              :error_category, :argument_error,
            )

            finish_with_error_event _ev
          end

          def via_everything_build_existant_path  # :+![#022]

            path = ::File.join @_parent_path, @filename

            if ! @filesystem.exist? path

              _mode = @filesystem.stat( @_parent_path ).mode
              @filesystem.mkdir path, _mode
            end

            path
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
        # <-


      # ==

      RuntimeError = ::Class.new ::RuntimeError
    end
  end
end
