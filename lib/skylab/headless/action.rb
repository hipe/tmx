module Skylab::Headless

  module Action
  end

  module Action::ModuleMethods

    def actions_anchor_module
      x = const_get :ACTIONS_ANCHOR_MODULE, true
      x.respond_to?( :call ) and x = x.call
      x
    end

    attr_reader :desc_lines

    def modalities_anchor_module
      x = const_get :MODALITIES_ANCHOR_MODULE, true
      x.respond_to?( :call ) and x = x.call
      x
    end

    def name_function
      @name_function ||= Headless::Name::Function::From::Module::Graph.new(
        name, actions_anchor_module.name )  # (one place in particular will be
    end  # upset if not all naming happens via this ivar !)

    def normalized_action_name
      name_function.normalized_name
    end
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


  protected

    def desc_lines                # we want this DSL-y module-methods part of
      self.class.desc_lines if self.class.respond_to? :desc_lines # it to be
    end                           # opt-in

    def formal_attributes         # hook for this experiment - [#049], [#036]
    end

    def formal_parameters         # idem
    end

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

    def normalized_action_name
      self.class.normalized_action_name
    end

    def normalized_local_action_name
      self.class.name_function.local.normalized_local_name
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

    def summary_line              # simple, modality-agnostic nerk
      if self.class.desc_lines
        self.class.desc_lines.first
      else
        "the #{ name.to_slug } action."
      end
    end
  end
end
