module Skylab::Treemap

  class Adapter::Catalyzer        # (at various times this was called 'mote'
                                  # and then 'metadata' but it started to
                                  # become this..)
                                  # a Catalyzer represents and _adapter_ (not
                                  # its action) and can load it.

    include Headless::Name::Function::InstanceMethods

    define_method :cli_action_names do
      if has_cli_actions
        MetaHell::Formal::Box::Enumerator.new( -> normalized_consumer do
          @module::CLI::Actions.constants.each do |const|
            nm = Headless::Name::Function.from_const const
            normalized_consumer.yield nm.local_normal, nm
            nil
          end
        end )
      end
    end

    def has_api_actions
      has_actions :API
    end

    def has_cli_actions
      has_actions :CLI
    end

    attr_reader :name  # name function

    def normalized_local_adapter_name
      @name.local_normal
    end

    def slug  # this makes maps much prettier, and is used as the 'against'
      @name.as_slug  # string in `fuzzy_reduce` for the adapter box.
    end       # (although we typically just call `name.as_slug`)

    def resolve_api_action_class tainted_a, error
      resolve_action_class :API, tainted_a, error
    end

    def resolve_cli_action_class tainted_a, error
      resolve_action_class :CLI, tainted_a, error
    end

  protected

    def initialize const, mod
      @const, @module = const, mod
      @name = Headless::Name::Function.from_const const
      @has_actions = { }
    end

    def catalyze_base_class mode               # `mode` e.g :CLI or :API
      # assumes that <mode> actions have been sussed out and exist
      mod = @module  # scope
      mode_mod = mod.const_get mode, false
      if ! mode_mod.constants.include? :Action
        kls = ::Class.new Treemap::const_get( mode, false )::Action
        mode_mod.const_set :Action, kls
        kls.class_eval do
          include(
            Treemap::Adapter.const_get( mode, false )::Action::InstanceMethods )
          const_set :ACTIONS_ANCHOR_MODULE, mode_mod::Actions
        end
      end
      nil
    end

    def has_actions mode
      @has_actions[ mode ].nil? and suss_actions mode
      @has_actions[ mode ]
    end

    def resolve_action_class mode, tainted_a, error
      res = false
      if has_actions mode
        const = @module.const_get( mode, false )::Actions.
          const_fetch( tainted_a, -> e do
            error[ "#{ slug } has no such #{ mode } action - #{ e.name }" ]
            end
          )
        if const
          res = const
        end
      else
        error[ "no #{ mode } actions" ]
      end
      res
    end

    def suss_actions mode
      has = false
      with_any mode, :Actions do |mod|
        if mod.constants.length.nonzero?
          has = true
        else  # for now we jump thru hacking hoops to keep this out of the
          if ! mod.respond_to? :boxxy_original_constants # adapter code
            mod.dir_pathname or fail 'sanity - recursive autloader?'
            mod.extend MetaHell::Boxxy::ModuleMethods
            mod.send :init_boxxy, nil
          end
          has = mod.constants.length.nonzero?
          catalyze_base_class mode
        end
      end
      @has_actions[ mode ] = has
      nil
    end

    def with_any *consts, &func
      found = consts.reduce @module do |memo, const|
        if memo.const_defined? const, false
          memo = memo.const_get const, false
        else
          # ( we debug here a lot )
          if memo.const_probably_loadable? const
            memo = memo.const_get const, false
          else
            break
          end
        end
        memo
      end
      func[ found ] if found
    end
  end
end
