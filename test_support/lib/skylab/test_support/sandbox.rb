module Skylab::TestSupport

  module Sandbox

  # A "sandbox" in this universe is always: a module used only in testing
  # (usually called 'Sandbox' and residing under a TestSupport module or
  # a nested child of one) that gets populated with constants (usually
  # Modules, e.g Classes) that are exclusively created to run tests on,
  # usually tests that test some kind of DSL-ish that operates on Classes
  # or Modules.
  #
  # These "sandbox" enhancements here, then, represent a year-ish worth of
  # distillation of such testy things we tended to do, things that were
  # intented to be more readable than [#ba-048] module & class creator
  # but more concise (and de-facto tagged) than writing these kind of things
  # always by hand.


  module Spawner

    #  top secret experiment

    def self.new
      ::Module.new.module_exec do
        @_cnt = 0
        extend Spawner_
        self
      end
    end

    module Spawner_
      def spawn
        # const_set "Sandbox_#{ @_cnt += 1 }", ::Module.new
        ::Module.new.extend Hax_
      end
    end

    module Hax_
      def with ctx
        self._NO_use_edit_with_context
      end

      def edit_with_context ctx
        @ctx = ctx
        nil
      end

      def eql x
        @ctx.eql x
      end

      def raise_error *a
        @ctx.raise_error( *a )
      end
    end
  end

  # `enhance` - this is for enhancing your Sandbox module with one
  # or more of these enhancements:
  #
  # `kiss_with` -
  # when you `kiss` a (always Module e.g Class) with your Sandbox module,
  # it simply `const_set`s that module "into" your Sandbox module, giving
  # it a name built by concatenating a prefix that you provide in your
  # call to `kiss_with` with a serial positive integer starting with one;
  # e.g if you provide the prefix "KLS_" for your `kiss_with` argument, then
  # each time you `Sandbox.kiss` something, it will be `const_set`
  # in your sandbox to `Sandbox::KLS_1`, `Sandbox::KLS_2` etc:
  #
  #     module Sandbox
  #       TestSupport::Sandbox.enhance( self ).kiss_with "KLS_"
  #     end
  #
  #     Sandbox.kiss some_func_that_builds_a_class[]
  #
  #     Sandbox::KLS_1  # => the class you created above.
  #
  # The main purpose of this is to give generated modules (e.g classes)
  # a readable name which can be nicer for debugging then trying to figure
  # out what e.g "#<Class:0x007fcae3806cd0>" is.
  #
  # In fact, more generally this kind of thing was the whole inspiration for
  # the first traceable ancestor of this library - Class::Creator.
  #
  #
  # `produce_subclasses_of` -
  # this enhancement gives your Sandbox module (itself) a method
  # `produce_subclass` which will, with each call to `Sandbox.produce_subclass`,
  # produce a subclass of the class you pass as an argument to
  # `produce_subclasses_of`, and it will `const_set` it into your Sandbox
  # module, giving it names like "KLS_1", "KLS_2", etc (kind of like
  # `kiss`).
  #
  # (oh, by the way, for now it is mandatory that your `superclass` be
  # a proc-ish that results in the superclass when `call`ed)

  def self.enhance sb_mod, &blk
    kiss_with = superklass = nil
    cnd = Shell_.new -> x { kiss_with = x }, -> x { superklass = x }
    flush = -> do
      Kernel_.new( sb_mod, kiss_with, superklass ).flush
      nil
    end
    if blk
      cnd.instance_exec( & blk )
      flush.call
    else
      cnd.class::One_Shot_.new cnd, flush
    end
  end

  Shell_ = Home_.lib_.plugin::Bundle::Enhance::Shell.new(
    :kiss_with, :produce_subclasses_of,
  )

  Kernel_ = Common_::Session::Ivars_with_Procs_as_Methods.new :flush do

    def initialize sb_mod, kiss_with, superklass
      @flush = -> do
        last_id = 0

        if kiss_with
          sb_mod.send :define_singleton_method, :kiss do |x|
            const_set "#{ kiss_with }#{ last_id += 1 }", x
          end
        end

        if superklass
          sb_mod.send :define_singleton_method, :produce_subclass do
            const_set "KLS_#{ last_id += 1 }", ::Class.new( superklass.call )
          end
        end ; nil
      end
    end
  end

  module Host

    # the `Host` enhancement (engaged only by `[]`) simply gives `anchor_mod`
    # a ModuleMethods module that defines `define_sandbox_constant`. assumes
    # an in-scope `Sandbox` module. #todo: example

    def self.[] anchor_mod
      Kernel_.new( anchor_mod ).flush
    end
  end

  Host::Kernel_ = Common_::Session::Ivars_with_Procs_as_Methods.new :flush do

    def initialize anchor_mod

      @flush = -> do
        mod = if anchor_mod.const_defined? :ModuleMethods, false
          anchor_mod.const_get :ModuleMethods, false
        else
          anchor_mod.const_set :ModuleMethods, ::Module.new
        end

        engine = nil
        if ! mod.method_defined? :define_sandbox_constant
          engine ||= Host::Engine_.new anchor_mod
          mod.send :define_method, :define_sandbox_constant, &
            engine.define_sandbox_constant_proc
        end ; nil
      end
    end
  end

  class Host::Engine_

    def initialize anchor_mod

      engine = self
      @define_sandbox_constant_proc = -> do
        -> i, & block_p do
          x = nil
          p = -> do
            p = nil
            sb = self::Sandbox
            list_a = sb.constants
            block_p[]  # execute this in its original context.
            list_b = sb.constants - list_a
            list_b.length.zero? and fail "no constants were added to #{
              }#{ sb } by block - #{ b }"
            x = sb.const_get( list_b.fetch( -1 ), false )
            engine.bust_autoloading x
            x
          end
          define_method i do
            p && p[]
            x
          end
        end
      end
    end

    def bust_autoloading x
      if ::Module === x
        x.extend Autoload_Buster_
      end ; nil
    end

    module Autoload_Buster_
      # sandboxes shouldn't have to support their nested modules that want
      # to do filesystem-based autoloading, except under special circumstances
      def dir_pathname
        nil
      end
    end

    Common_::Session::Ivars_with_Procs_as_Methods[ self ].
      as_public_getter :define_sandbox_constant_proc  # grease

  end
  end
end
