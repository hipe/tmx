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
    # More specifically, Regret was inspired by the fact that most of our
    # TestSupport modules have the following in common:
    #
    #   + They usually define a ModuleMethods and an InstanceMethods
    #   + They have the usual impelemtation of extended() which is to include
    #       one and extend the other of the above on the extending module.
    #   + These two modules always include their "parents" if any.
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
      if parent_anchor_module
        include parent_anchor_module # #constants
      end

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
