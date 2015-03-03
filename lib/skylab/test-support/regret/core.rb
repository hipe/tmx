module Skylab::TestSupport

  module Regret  # read [#017] the introduction to regret

    class << self

      def [] mod
      if ! mod.respond_to? :dir_pathname  # #storypoint-35
        s_a = mod.name.split CONST_SEP_  # rewrite of :+[#ba-034]
        s_a.pop
        _parent_mod = s_a.reduce( ::Object ) { |m, s| m.const_get s, false }
        Autoloader_[ mod, _parent_mod.dir_pathname.join( TEST_DIR_FILENAME_ ) ]
      end
      mod.extend Anchor_ModuleMethods
      mod.initialize_for_regret_with_parent_anchor_mod nil
      end
    end

    module Anchor_ModuleMethods

      def [] mod, * x_a
        if ! mod.respond_to? :dir_pathname
          s = mod.name
          autoloaderize_with_filename_child_node(
            Callback_::Name.via_const( s[ s.rindex( CONST_SEP_ ) + 2 .. -1 ] ).as_slug,
            mod )
        end
        mod.extend Anchor_ModuleMethods
        mod.initialize_for_regret_with_parent_anchor_mod self
        x_a.length.nonzero? and
          apply_x_a_on_child_test_node x_a, mod  # :#hook-out
        nil
      end

    private

      def extended mod
        mod.extend module_methods_module
        mod.include instance_methods_module
        mod.include constants_module  # became necessary in 1.9.3
        nil
      end

    public

      def initialize_for_regret_with_parent_anchor_mod pam

        @parent_anchor_module = pam  # nil ok

        o = Bump_module__.curry[ self ]

        o[ :Constants, -> do
          pam and include pam.constants_module
        end ]

        test_module_me = self

        o[ :ModuleMethods, -> do
          pam and include pam.module_methods_module
          if ! instance_methods( false ).include? NEAREST__
            # if not multiparent. if not custom hacks
            define_method NEAREST__ do test_module_me end
          end
        end ]

        o[ :InstanceMethods, -> do
          extend TestSupport_.lib_.let::ModuleMethods
          pam and include pam.instance_methods_module
        end ]

        nil
      end

      def parent_anchor_module
        @parent_anchor_module  # notices please
      end

    # ~ as parent

      def constants_module
        const_get :Constants, false
      end

      def instance_methods_module
        const_get :InstanceMethods, false
      end

      def module_methods_module
        const_get :ModuleMethods, false
      end

    private  # extension experiment - all the extensions

      def set_tmpdir_pathname &blk
        load_extension_and_recall :Tmpdir_, nil, blk
      end

      def set_command_parts_for_system_under_test *a, &b
        load_extension_and_recall :SUT_Command_, a, b
      end

      def add_command_parts_for_system_under_test *a, &b
        load_extension_and_recall :SUT_Command_, a, b
      end

      # ~ extension experiment - support ~

      def load_extension_and_recall extension_name_i, a=nil, b=nil
        Regret::Extensions_.const_get extension_name_i, false
        loc = caller_locations( 1, 1 )[ 0 ]
        send loc.base_label, *a, &b  # OMG LOOKOUT
      end

      def topless_errmsg msg
        "top not found - you'd better #{ msg } in #{ self } because #{
          }somebody is looking for it"
      end

      def count_to_top
        if parent_anchor_module
          1 + parent_anchor_module.count_to_top
        else
          0
        end
      end
      public :count_to_top
    end
    #
    Bump_module__ = -> host_module, const, p=nil do
      mod = if host_module.const_defined? const, false
        host_module.const_get const, false
      else
        host_module.const_set const, ::Module.new
      end
      p and mod.module_exec( & p )
      mod
    end

    NEAREST__ = :nearest_test_node
    Regret_ = self

  end
end
