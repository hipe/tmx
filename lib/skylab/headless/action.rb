module Skylab::Headless

  module Action

    def self.[] mod, * x_a
      Bundles.apply_iambic_on_client x_a, mod
    end

    module Bundles

      Actions_anchor_module = -> x_a do
        x = x_a.shift
        _p = if x.respond_to? :call then x
        elsif x.respond_to? :id2name then
          -> { const_get x }
        else
          -> { x }
        end
        const_set :ACTIONS_ANCHOR_MODULE_P___, _p ; nil
      end

      Anchored_names = -> x_a do
        extend Anchored_Name_MMs
        def name
          self.class.name_function.local  # life is easier this way
        end
        if x_a.length.nonzero? and :with == x_a.first
          x_a.shift
          Keyword_required__[ :name_waypoint_module, x_a ]
          module_exec x_a, & Actions_anchor_module.to_proc
        end ; nil
      end

      Client_services = -> x_a do
        module_exec x_a, & Headless::Client_Services.to_proc
      end

      Core_instance_methods = -> _ do
        include IMs ; nil
      end

      Expressive_agent = -> _ do
        module_exec _, & Headless::Pen::Bundles::Expressive_agent.to_proc
      end

      Inflection = -> _ do
        extend Headless::NLP::EN::API_Action_Inflection_Hack ; nil
      end

      MetaHell::Bundle::Multiset[ self ]

    end

    Keyword_required__ = -> i, x_a do
      i == x_a.first or raise ::ArgumentError, "expected '#{ i }' had #{
        }#{ Headless::FUN::Inspect[ x_a.first ] }"
      x_a.shift ; nil
    end

    module Anchored_Name_MMs

      def normalized_action_name
        name_function.anchored_normal
      end

      def name_function
        @name_function ||= Headless::Name::Function::From::Module_Anchored.
          new name, actions_anchor_module.name
      end

      alias_method :full_name_proc, :name_function # #hook-out legacy

      def actions_anchor_module
        const_get( :ACTIONS_ANCHOR_MODULE_P__, true ).call
      end

      def modalities_anchor_module
        x = const_get :MODALITIES_ANCHOR_MODULE, true
        x.respond_to?( :call ) and x = x.call
        x
      end
    end

    module IMs

      include Headless::SubClient::InstanceMethods

      # read [#138] the action narrative #storypoint-1

    private

      def formal_attributes
        # a #hook-out/:#hook-in for [#036] the parameter labels experiment
      end

      def formal_parameters
        # a #hook-out/:#hook-in for [#049] the formal params experiment
      end

    protected  # #protected-not-private

      def is_branch  # #storypoint-2 **NOT** a :#hook-in
        ! is_leaf
      end

      def is_leaf  # :#hook-in
        true
      end

      def normalized_local_action_name
        self.class.name_function.local.local_normal
      end

    private

      def normalized_action_name
        self.class.normalized_action_name
      end

      def parameter_label x, idx=nil  # [#036] explains it all
        if formal_parameters
          fp = formal_parameters.fetch( x ) { }
        end
        if ! fp && formal_attributes
          fp = formal_attributes.fetch( x ) { }
        end
        request_client.send :parameter_label, ( fp || x ), idx
      end
    end
  end
end
