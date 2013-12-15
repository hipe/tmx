module ::Skylab::TestSupport

  module Regret  # full introduction at [#017], notes at [#016]

    def self.[] mod
      mod.module_exec do
        extend Regret::Anchor_ModuleMethods
        init_regret caller_locations( 3, 1 )[ 0 ], nil
      end
      nil
    end

    module Anchor_ModuleMethods

      include Autoloader::Methods

      def [] child_mod, loc=nil
        loc ||= caller_locations( 1, 1 )[ 0 ]
        parent_anchor_module = self
        child_mod.module_exec do
          extend Anchor_ModuleMethods
          init_regret loc, parent_anchor_module
        end
        nil
      end

    private

      def extended mod
        mod.extend module_methods_module
        mod.send :include, instance_methods_module
        mod.send :include, constants_module  # for 1.9.3
        nil
      end

      alias_method :regret_extended_notify, :extended

      def init_regret loc, pam

        @parent_anchor_module = pam  # nil ok

        tug_class.nil? and  # if you set it to false you are crazy
          @tug_class = MetaHell::Autoloader::Autovivifying::Recursive::Tug

        dpn = Twerk_dir_pathname_[ loc, pam, -> x do
          init_autoloader x ; @dir_pathname
        end ]
        dpn and @dir_pathname = dpn  # ( you can witness the change here )

        o = Bump_module_.curry[ self ]

        o[ :CONSTANTS, -> do
          pam and include pam.constants_module
        end ]

        o[ :ModuleMethods, -> do
          pam and include pam.module_methods_module
        end ]

        o[ :InstanceMethods, -> do
          extend ::Skylab::MetaHell::Let::ModuleMethods # or fly solo .. #rspec
          pam and include pam.instance_methods_module
        end ]

        nil
      end

      def parent_anchor_module
        @parent_anchor_module  # notices please
      end

    public  # as parent

      def constants_module
        const_get :CONSTANTS, false
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
    Bump_module_ = -> host_module, const, p=nil do
      mod = if host_module.const_defined? const, false
        host_module.const_get const, false
      else
        host_module.const_set const, ::Module.new
      end
      p and mod.module_exec( & p )
      mod
    end
    #
    Twerk_dir_pathname_ = -> loc, pam, init_al_p do
      if pam && SPEC_TAIL_ == loc.path[ SPEC_TAIL_POS_ .. -1 ]
        Dir_pn_from_strange_location_[ loc, pam ]
      else
        dir_pn = init_al_p[ loc ]
        TS_NAME_ == dir_pn.basename.to_s and dir_pn.dirname
      end
    end
    #
    SPEC_TAIL_ = Subsys::FUN::Spec_rb[]
    SPEC_TAIL_POS_ = - SPEC_TAIL_.length
    TS_NAME_ = 'test-support'.freeze
    #
    Dir_pn_from_strange_location_ = -> loc, pam do
      pam.dir_pathname.join SPEC_RX_.match( loc.path )[ :stem ]
    end
    #
    SPEC_RX_ = %r{\A
      (?<dir>.+[^/]) / (?<stem>[^/]+) #{ ::Regexp.escape SPEC_TAIL_ }
    \z}x
  end
end
