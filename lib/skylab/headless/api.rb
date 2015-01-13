module Skylab::Headless

  module API  # read [#017] the API node narrative (was (historical) [#010])

    # in this document the [#119] abbreviations in method names mean something

    class << self

      def [] mod, * x_a
        via_client_and_iambic mod, x_a
      end

      def call_via_arglist x_a
        via_client_and_iambic x_a.shift, x_a
      end

      def via_client_and_iambic mod, x_a
        Bundles__.apply_iambic_on_client x_a, mod ; nil
      end
    end

    Headless_.const_get :Library_, false

    module Bundles__
      # ~ in dependency order!
      With_service = -> _ do  # #storypoint-10
        extend Service_Methods_for_Toplevel_Module__ ; nil
      end
      With_session = -> _ do  # #storypoint-15
        extend Session_Methods_for_Toplevel_Module__
        service_class.extend Session_Methods_for_Service_Class__ ; nil
      end
      With_actions = -> _ do  # #storypoint-20
        module_exec( & Touch_dir_patname__ )
        const_set :Actions, ::Module.new
        const_defined?( :Action, false ) or
          const_set :Action, ::Class.new( Iambic_Action__ )
        define_singleton_method :action_class do end  # future-proofing
      end
      Headless_.lib_.bundle::Multiset[ self ]
    end

    Touch_dir_patname__ = -> do
      Has_dpn__[ self ] or module_exec( & Rslv_Dpn__ )
    end

    Has_dpn__ = -> x do
      x.respond_to? :dir_pathname and x.dir_pathname
    end

    Rslv_Dpn__ = -> do  # #storypoint-25
      parent = Headless_.lib_.module_lib.value_via_relative_path self, '..'
      parent and Has_dpn__[ parent ] or fail "no support for toplevel modules"
      Autoloader_[ self ] ; nil
    end

    module Service_Methods_for_Toplevel_Module__

      def invoke * x_a  # :+[#sl-121] the standard façade
        x_a.unshift :action_locator_x
        svc_singleton.invoke_with_iambic x_a  # #storypoint-30
      end

      def invoke_with_iambic x_a
        x_a.unshift :action_locator_x
        svc_singleton.invoke_with_iambic x_a
      end

    private
      def svc_singleton
        @svc_singl ||= bld_service
      end

      def bld_service
        service_class.new
      end

      def service_class
        if const_defined? :Service, false
          const_get :Service
        else
          const_set :Service, bld_service_class
        end
      end

      def bld_service_class
        toplevel_module = self
        ::Class.new.class_exec do
          include Service_Instance_Methods__
          const_set :API_MODULE, toplevel_module
          self
        end
      end
    end

    module Service_Instance_Methods__
      def invoke_with_iambic x_a
        x_a.unshift :service, self
        sssn_cls.new( x_a ).execute
      end
      def sssn_cls
        self.class.session_cls
      end
    end

    module Session_Methods_for_Service_Class__
      def session_cls
        tplvl_module.session_class
      end
    private
      def tplvl_module
        const_get :API_MODULE, false
      end
    end

    module Session_Methods_for_Toplevel_Module__
      def session_class
        if const_defined? :Session, false
          const_get :Session
        else
          const_set :Session, bld_session_class
        end
      end
    private
      def bld_session_class
        toplevel_module = self
        ::Class.new.class_eval do
          include Session_Instance_Methods__
          const_set :API_MODULE, toplevel_module
          self
        end
      end
    end

    module Session_Instance_Methods__

      # this module is a minimal methodic actor #:+#public-API

      Callback_::Actor.methodic self, :properties,
        :action_locator_x,
        :errstream,
        :service,
        :unbound_action_box

      def initialize x_a  # mutates the scan, "parses-off" what it takes. #todo this should pass a stream not an array
        st = iambic_stream_via_iambic_array x_a
        d = st.current_index
        process_iambic_stream_passively st
        @local_mutable_iambic = if d == st.current_index
          EMPTY_A_  # it's a trap
        else
          x_a[ 0, st.current_index ] = EMPTY_A_
          x_a
        end
        rslv_errstream
        rslv_unbound_action_box ; nil
      end
    private
      def rslv_errstream
        @errstream ||= Headless_.system.IO.some_stderr_IO ; nil
      end
      def rslv_unbound_action_box
        @unbound_action_box ||= self.class::API_MODULE::Actions
      end
    public
      def execute
        ok = rslv_bound_action_trio
        ok and @bound_action.send( @method_name, * @args )
      end
    private
      def rslv_bound_action_trio
        @unbound_action = any_unbnd_action
        @unbound_action and rslv_bound_action_trio_from_unbound_action
      end
      def any_unbnd_action
        Autoloader_.const_reduce do |cr|
          cr.const_path [ @action_locator_x ]
          cr.from_module @unbound_action_box
          cr.else_p method :unbnd_action_not_found
        end
      end
      def unbnd_action_not_found name_error
        raise ::NameError, say_nm_error( name_error )
      end
      def say_nm_error name_error
        "cannot \"#{ name_error.name }\" - there is no such constant #{
          }#{ name_error.module.name }::( ~ #{ name_error.name } )"
      end
      def rslv_bound_action_trio_from_unbound_action
        if @unbound_action.respond_to? :to_proc
          rslv_bound_action_trio_from_unbound_action_that_looks_like_proc
        else
          rslv_bound_action_trio_from_unbound_action_that_looks_like_class
        end
      end
      def rslv_bound_action_trio_from_unbound_action_that_looks_like_proc
        @bound_action = @unbound_action
        @method_name = :[]
        @args = release_local_mutable_iambic
        true
      end
      def rslv_bound_action_trio_from_unbound_action_that_looks_like_class
        _x = release_local_mutable_iambic
        _seed = Action_Seed__.new _x, @errstream, self, @service
        @bound_action = @unbound_action.new _seed
        @method_name = :execute
        @args = nil
        true
      end
      Action_Seed__ = ::Struct.new :iambic, :errstream, :session, :service

      def release_local_mutable_iambic
        x = @local_mutable_iambic ; @local_mutable_iambic = nil ; x
      end
    end

    class Iambic_Action__

      Callback_::Actor.methodic self, :simple, :properties,
        :properties, :errstream, :service, :session

      def initialize x_a=nil  # #todo pass stream not array
        if x_a
          process_iambic_stream_fully iambic_stream_via_iambic_array x_a
          nilify_uninitialized_ivars
        end
        super()
      end
      def say_unexpected_iambic
        "#{ super } for \"#{ self.class.name_function.as_natural }\" action"
      end
      class << self
        def name_function
          @name_function ||= bld_name_function
        end
        def bld_name_function
          Callback_::Name.via_module self
        end
      end
    end

    Iambic_Action = Iambic_Action__

  end
end
