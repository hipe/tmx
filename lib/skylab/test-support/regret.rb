module ::Skylab::TestSupport

  module Regret

    # As the name suggests, we might really regret this. (This was [#ta-019].)
    #
    # The Regret module is an alternate way to do something like rspec's
    # shared_contexts but with an implementation that is in some ways more
    # transparent and less opaque, while still in other ways being possibly
    # too opaque.
    #
    # Regret represents a distillation of patterns and conventions that
    # were developed while making the sprawling tests for this
    # and other submodules.
    #
    # Specifically, Regret was inspired by the fact that most of our
    # TestSupport modules have the following in common:
    #
    #   + They usually define a ModuleMethods and an InstanceMethods
    #     (the module that has two above modules inside of it we refer to
    #     here as an "anchor module".)
    #   + They have the usual implemtation of extended() which is to include
    #     one and extend the other of the above on the extending module.
    #   + These two modules always include their "parents" if any.
    #     (Where, if you have Foo::M_M and Foo::I_M and Bar::M_M and Bar::I_M,
    #     and Bar is actually inside Foo (Foo::Bar), the "parent" of
    #     Bar::M_M is Foo::M_M and the "parent" of Bar::I_M is Foo::I_M.)
    #   + They sometimes want to at least be some kind of autoloader, possibly
    #     with a dir_path that is nonstandard in a consistent way.
    #   + The InstanceMethods module pulls in the module called Let
    #   + There is a CONSTANTS module that forms a central place to hold
    #     application constants.
    #   + They might want to have a tmpdir, named and sandboxed
    #     appropriately.
    #
    # For our implementation of Regret itself as it will be used in the field,
    # we use the "embellish" (or []) method.  Subsequent uses of it down the
    # nodes of the tree will use the [] method of the parent module
    #
  end

  module Regret::MyModuleMethods

    def embellish mod
      mod.module_exec do
        extend Regret::AnchorModuleMethods
        init_regret caller[2]
      end
      nil
    end

    alias_method :[], :embellish
  end

  Regret.extend Regret::MyModuleMethods

  module Regret::AnchorModuleMethods

    include Autoloader::Methods   # a regrettified module is an a.l module
                                  # that we twerk out a bit

    def edify child_mod
      me = self
      child_mod.module_exec do
        extend Regret::AnchorModuleMethods
        init_regret caller[2], me
      end
      nil
    end

    alias_method :[], :edify

    def extended mod
      mod.extend module_methods_module
      mod.send :include, instance_methods_module
    end

    alias_method :_regret_extended, :extended


    # There's clearly lots of room for making this more configurable, but at
    # this phase, this is just a proof of concept geared around duplicating
    # and DRY-ing up what's happening in the tests now.
    #


    spec_tail = "_spec#{ Autoloader::EXTNAME }"
    spec_tail_len = spec_tail.length
    spec_rx = %r| \A  (?<dir>.+[^/])  /
                      (?<stem>[^/]+) #{ ::Regexp.escape spec_tail } \z |x

    define_method :init_regret do |caller_str, parent_anchor_module=nil|

      # *note*: We do *not* include the parent_anchor_module itself
      # into this client anchor_module.  If you do, with our chosen naming
      # convention it will have the effect of having the test-support
      # anchor modules masking the client modules of the same name:
      #
      #   e.g.:  MyApp::Mod_1                      # business logic for your app
      #          MyApp::Mod_1::Mod_A               # this holds some sub-content
      #          MyApp::TestSupport                # your root test support mod
      #          MyApp::TestSupport::Mod_1         # test support for same
      #          MyApp::TestSupport::Mod_1::Mod_A  # test support for same
      #
      #
      #   If you are either directly "inside" TS::Mod_1::Mod_A or you are in
      #   a module that has included same, and you say `Mod_1`, which Mod_1
      #   do you mean?  It's arguably bad design to mean T_S::Mod_1
      #   (so confusing!) but that's what you would get if anchor modules
      #   included their parent anchor modules.  I bet it's crystal clear now,
      #   eh!?
      #
      # If you want constants to be "inherited down" from one anchor module
      # to another, the place to do that is e.g. in a module called CONSTANTS
      # that resides in your anchor module.  You would then include that
      # CONSTANTS module in your I_M or your M_M as appropriate. in flux!
      #
      # (Now, experimentally, we are doing the above)

      if tug_class.nil?  # if you set it to false you are crazy
        @tug_class = MetaHell::Autoloader::Autovivifying::Recursive::Tug
      end

      -> do
        # experimental filesystem architecture (merged trees)
        is_normal = true
        if parent_anchor_module   # here have a hack so that instead of
          # it needing to live in foo/test-support.rb it can be in foo_spec.rb
          md = Headless::FUN.call_frame_rx.match caller_str
          if spec_tail == md[:path][ - spec_tail_len, spec_tail_len ]
            is_normal = false
            stem = spec_rx.match( md[:path] )[:stem]
            @dir_pathname = parent_anchor_module.dir_pathname.join stem
            init_autoloader nil
          end
        end
        if is_normal
          init_autoloader caller_str
          if 'test-support' == dir_pathname.basename.to_s  # here have a hack
            # so that when it *is* is 'test-support' we "correct" the path
            # (life is better *without* test-support folders trust me!)
            @dir_pathname = dir_pathname.join('..')
          end
        end
      end.call

      const_set :CONSTANTS, -> do
        o = ::Module.new
        parent_anchor_module and
          o.send :include, parent_anchor_module.constants_module
        o
      end.call

      const_set :ModuleMethods, -> do
        o = ::Module.new
        parent_anchor_module and
          o.send :include, parent_anchor_module.module_methods_module
        o
      end.call

      const_set :InstanceMethods, -> do
        o = ::Module.new
        o.module_eval {
          extend ::Skylab::MetaHell::Let::ModuleMethods # or fly solo .. #rspec
          parent_anchor_module and
            include parent_anchor_module.instance_methods_module
        }
        o
      end.call

      define_singleton_method :parent_anchor_module do # nil ok!
        parent_anchor_module
      end

      nil
    end

    protected :init_regret

    def constants_module
      const_get :CONSTANTS, false
    end

    def count_to_top
      if parent_anchor_module
        1 + parent_anchor_module.count_to_top
      else
        0
      end
    end

    def instance_methods_module
      const_get :InstanceMethods, false
    end

    def module_methods_module
      const_get :ModuleMethods, false
    end

    def tmpdir
      @tmpdir ||= begin
        TestSupport_::Tmpdir.new path: tmpdir_pathname,
          max_mkdirs: ( count_to_top + 1 ) # one for tmp/your-sub-product
      end
    end

    def tmpdir_pathname
      @tmpdir_pathname ||= begin
        pam = parent_anchor_module or raise "You better set #{
          }@tmpdir_pathname in #{ self } because somebody is looking for it."
        par = parent_anchor_module.tmpdir_pathname
        dir = Autoloader::Inflection::FUN.pathify[
          name[ name.rindex( ':' ) + 1 .. -1 ] ]
        par.join dir
      end
    end

    attr_writer :tmpdir_pathname

  protected

    # nothing is protected.

  end
end
