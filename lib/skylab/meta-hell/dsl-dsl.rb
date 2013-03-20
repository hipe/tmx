module Skylab::MetaHell

  module DSL_DSL

    # extend a `ModuleMethods`-ish module with `DSL_DSL` and call e.g
    # `dsl_dsl { atom :foo ; atom :bar ; list :baz }` on it. Your module
    # then has memoizing getter/setters for `foo`, `bar`, `baz` at the module-
    # level, and getters at the instance level.
    #
    # (This is basically like the `let` of ::Rspec fame, except it makes
    # sugar for you. I WILL CALL IT SUGAR FACTORY)
    #
    # `list` type behaves like `atom` type identically except it globs
    # the incoming args when setting.  `block` works as expected, too,
    # if you're expecting the right thing

    def dsl_dsl &block
      story = Story.new self
      story.instance_exec(& block )
      nil
    end

    class Story

      def atom name
        @atom[ name ]
      end

      def atom_accessor name
        @atom_accessor[ name ]
      end

      def list name
        @list[ name ]
      end

      def block name
        @block[ name ]
      end

    protected

      def initialize mod
        # crystal clear, yeah? if the module caller says it wants an `atom`
        # with name <foo>, then, out of the box it will have a "get_<foo>"
        # that results in nil. If ever you call `foo "wizzle"` on that module,
        # it will do 2 things: 1) change the definition of `get_<foo>`
        # to result in that value ("wizzle"), 2) give the module an instance
        # method that does the same thing, but by the name `foo` (there is
        # no setter (or setting) `foo` at the instance level with this
        # facility).

        @atom, @list, @block = mod.module_exec do
          atom = -> name do
            define_method "get_#{ name }" do end
            define_method name do |monadic_x|
              define_singleton_method "get_#{ name }" do monadic_x end
              define_method name do monadic_x end
              nil
            end
            nil
          end

          list = -> name do
            define_method "get_#{ name }" do end  # some might []
            define_method name do |* x_a|
              x_a.freeze  # at the instance level we don't want to accidentally
                          # mutate it (the same *should* apply to the mod-level)
              define_singleton_method "get_#{ name }" do x_a end
              define_method name do x_a end
              nil
            end
            nil
          end
            # `list` acts same as `atom` but it globs the incoming argument(s)
            # so that it "just works" "as expected" ("") for a list-like field.

          block = -> name do
            define_method "get_#{ name }" do end
            define_method name do |&blk|
              blk or raise ::ArgumentError, "block required"
              define_singleton_method "get_#{ name }" do blk end
              define_method name do blk end
              nil
            end
            nil
          end
            # `block` is identical to `atom` except for the "globbing" and the
            # check that a block was passed.

          [ atom, list, block ]
        end

        @atom_accessor = -> sym do

          reader = "get_#{ sym }".intern
          writer = "#{ sym }=".intern

          mod.module_exec do

            attr_accessor sym                  # make the reader and the writer
            alias_method reader, sym           # reader `foo` becomes `get_foo`

            sig_a = [ reader, writer ]

            define_method sym do |*a|
              send sig_a.fetch( a.length ), *a
            end
          end
          nil
        end
      end
    end
  end
end
