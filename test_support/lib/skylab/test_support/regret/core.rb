module Skylab::TestSupport

  module Regret  # read [#017] the introduction to regret

    class << self

      def [] mod, dir

        if mod.respond_to? :dir_pathname
          self._WHERE
        else
          Autoloader_[ mod, dir ]
        end

        mod.extend Anchor_ModuleMethods
        mod._initialize_for_regret_with_parent_anchor_mod nil
      end
    end  # >>

    module Anchor_ModuleMethods

      def [] mod, * x_a

        # enhance the module with autoloading IFF:
        #
        #   • it wasn't turned off explicitly in this call -AND-
        #   • it wasn't turned off in the parent enhancement module -AND-
        #   • the module doesn't already evince autoloading -AND-

        autoloading_maybe = _autoloading_maybe

        if x_a.length.nonzero?

          autoloading_maybe, filename = ___parse_parameters x_a, mod
        end

        if autoloading_maybe and ! mod.respond_to? :dir_pathname

          if filename
            using_file_entry_string_autoloaderize_child_node filename, mod
          else
            autoloaderize_child_node mod
          end
        end

        mod.extend Anchor_ModuleMethods

        mod._initialize_for_regret_with_parent_anchor_mod self

        NIL_
      end

      def ___parse_parameters x_a, mod

        st = Common_::Polymorphic_Stream.via_array x_a

        yes = _autoloading_maybe

        if yes

          if :filename == st.current_token

            st.advance_one
            filename = st.gets_one

          elsif :autoloading == st.current_token

            st.advance_one
            if :none != st.current_token
              raise ::ArgumentError, self._WRITE_ME__say_missing( st )
            end
            st.advance_one

            mod.send :define_singleton_method, :_autoloading_maybe do
              false
            end  # we don't know at this point is mod is terminal or not

            yes = false
          end
        end

        if st.unparsed_exists
          raise ::ArgumentError, self._WRITE_ME__say_extra( st )
        end

        [ yes, filename ]
      end

      def _autoloading_maybe
        true
      end

      def extended mod
        mod.extend module_methods_module
        mod.include instance_methods_module
        mod.include constants_module  # became necessary in 1.9.3
        nil
      end

      def _initialize_for_regret_with_parent_anchor_mod pam

        @parent_anchor_module = pam  # nil ok

        o = Touch_module___.curry[ self ]

        o.call :Constants do
          if pam
            include pam.constants_module
          end
        end

        test_module_me = self

        o.call :ModuleMethods do

          if pam
            include pam.module_methods_module
          end

          if ! instance_methods( false ).include? NEAREST__
            # if not multiparent. if not custom hacks
            define_method NEAREST__ do test_module_me end
          end
        end

        o.call :InstanceMethods do

          if ! singleton_class.method_defined? :let  # #todo away this

              # some define it early to use it inline

            define_singleton_method :let, Home_::Let::LET_METHOD
          end

          if pam
            include pam.instance_methods_module
          end
        end

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

    Touch_module___ = -> host_module, const, & p do

      mod = if host_module.const_defined? const, false
        host_module.const_get const, false
      else
        host_module.const_set const, ::Module.new
      end

      if p
        mod.module_exec( & p )
      end

      mod
    end

    NEAREST__ = :nearest_test_node
    Regret_ = self

  end
end
