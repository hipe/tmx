module Skylab::Headless

  module Action

    def self.[] mod, * x_a
      Bundles.apply_iambic_on_client x_a, mod
    end

    module Bundles

      Anchored_names = -> x_a do
        :with == x_a[ 0 ] or fail "expecting 'with'" ; x_a.shift
        :name_waypoint_module == x_a[ 0 ] or fail "expecting 'n..'" ; x_a.shift
        _p = x_a.shift
        const_set :ACTIONS_ANCHOR_MODULE, _p ; nil  # #todo
      end

      Client_services = -> x_a do
        module_exec x_a, & Headless::Client_Services.to_proc
      end

      Expressive_agent = -> _ do
        module_exec _, & CLI::Pen::Bundles::Expressive_agent.to_proc
      end

      Inflection = -> _ do
        extend Headless::NLP::EN::API_Action_Inflection_Hack ; nil
      end

      MetaHell::Bundle::Multiset[ self ]

    end
  end

  module Action::ModuleMethods

    def actions_anchor_module
      x = const_get :ACTIONS_ANCHOR_MODULE, true
      x.respond_to?( :call ) and x = x.call
      x
    end

    def modalities_anchor_module
      x = const_get :MODALITIES_ANCHOR_MODULE, true
      x.respond_to?( :call ) and x = x.call
      x
    end

    def name_function
      @name_function ||= Headless::Name::Function::From::Module_Anchored.new(
        name, actions_anchor_module.name )  # (one place in particular will be
    end  # upset if not all naming happens via this ivar !)

    alias_method :full_name_proc, :name_function  # this is necessary
      # to give some crossover compatibilty with legacy action sheets, which
      # have name fuctions that are not full.

    def normalized_action_name
      name_function.anchored_normal
    end

    def _headless_init_add x
      ( @_headless_inits ||= [] ) << x  # #experimental
    end

    attr_reader :_headless_inits  # #experimental
  end

  module Action::InstanceMethods
    include Headless::SubClient::InstanceMethods

    # **NOTE** *any* public methods defined below are very #experimental
    # while we decide what the set of `public` should be for is for and how
    # action objects (in their many various incarnations) are used here..

    def name                      # life is much easier if when we say `name`
      self.class.name_function.local  # of an an action object, we are talking
    end                           # about the local (tail) element of the
                                  # action class's name function.

  private

    def formal_attributes         # hook for this experiment - [#049], [#036]
    end

    def formal_parameters         # idem
    end

  protected  # #protected-not-private

    def is_branch                 # brach == non terminal == box. bc it has far
      ! is_leaf                   # reaching consequences for request processing
    end                           # awareness of branchiness is baked-in deep.
                                  # it is recommended that you *not* redefine
                                  # this anywhere universe-wide, and rather hack
                                  # `is_leaf` if you need to, for reasons.
                                  # (it is this way and not the reverse
                                  # for reasons.)

    def is_leaf                   # out of the (heh) "box" we assume we are
      true                        # a terminal action and not a box action
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

    def _headless_inits_run  # assumes self.class._headless_inits
      @_headless_inits_ran_h ||= ::Hash.new { |h, k| h[k] = true ; nil }
      self.class._headless_inits.each do |method_name|
        if @_headless_inits_ran_h[ method_name ]
          fail "sanity - already ran: #{ method_name } - figure this logic out"
        else
          send method_name
        end
      end
      nil
    end
  end
end
