module ::Skylab::TestSupport
  module Regret
    # As the name suggests, we might really regret this. (This was [#tm-019].)
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
    #       (the module that has two above modules inside of it we refer to
    #        here as an "anchor module".)
    #   + They have the usual implemtation of extended() which is to include
    #       one and extend the other of the above on the extending module.
    #   + These two modules always include their "parents" if any.
    #       (Where, if you have Foo::M_M and Foo::I_M and Bar::M_M and Bar::I_M,
    #       and Bar is actually inside Foo (Foo::Bar), the "parent" of
    #       Bar::M_M is Foo::M_M and the "parent" of Bar::I_M is Foo::I_M.)
    #   + They sometimes want to at least be some kind of autoloader, possibly
    #       with a dir_path that is nonstandard in a consistent way.
    #   + The InstanceMethods module pulls in the module called Let
    #
    # For our implementation of Regret itself as it will be used in the field,
    # we use the "embellish" (or []) method.  Subsequent uses of it down the
    # nodes of the tree will use the [] method of the parent module
    #
  end

  module Regret::MyModuleMethods

    def embellish mod
      mod.extend Regret::AnchorModuleMethods
      mod._init_regret! caller[0]
    end
    alias_method :[], :embellish
  end

  Regret.extend Regret::MyModuleMethods

  module Regret::AnchorModuleMethods

    def edify child_mod
      child_mod.extend Regret::AnchorModuleMethods
      child_mod._init_regret! caller[0], self
    end
    alias_method :[], :edify

    def extended mod
      mod.extend module_methods_module
      mod.send :include, instance_methods_module
    end
    alias_method :regret_extended, :extended


    # There's clearly lots of room for making this more configurable, but at
    # this phase, this is just a proof of concept geared around duplicating
    # and DRY-ing up what's happening in the tests now.
    #
    def _init_regret! caller_str, parent_anchor_module = nil
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

      extend ::Skylab::MetaHell::
        Autoloader::Autovivifying::Recursive::ModuleMethods #conf

      -> do
        # experimental filesystem architecture (merged trees)
        _autoloader_extended! caller_str
        if 'test-support' == dir_pathname.basename.to_s
          self.dir_pathname = dir_pathname.join('..')
          # life is better without test-support folders
        end
      end.call
      const_set :ModuleMethods, -> do
        o = ::Module.new
        if parent_anchor_module
          o.module_eval {
            include parent_anchor_module.module_methods_module
          }
        end
        o
      end.call
      const_set :InstanceMethods, -> do
        o = ::Module.new
        o.module_eval {
          extend ::Skylab::MetaHell::Let::ModuleMethods # or fly solo .. #rspec
          if parent_anchor_module
            include parent_anchor_module.instance_methods_module
          end
        }
        o
      end.call
    end
    def instance_methods_module
      const_get :InstanceMethods, false
    end
    def module_methods_module
      const_get :ModuleMethods, false
    end
    protected
  end
end
