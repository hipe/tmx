module Skylab::Treemap
  module Adapter::InstanceMethods::CLI_Action
    include Adapter::InstanceMethods::Action

  protected

    def _adapter_init
      @active_adapter_action_id = nil
      @adapter_action_cache = { }
      nil
    end

    def enhance_with_adapter ref
      ref ||= api_action.formal_attributes[:adapter_name][:default]
      with_adapter_cli_action [ref, :render], -> act do
        if @active_adapter_action_id != act.object_id
          @active_adapter_action_id = act.object_id
          act.load_attributes_into api_action.formal_attribute_definer
          act.load_options_into self
          true
        end
      end, -> failed do
        info failed
        usage_and_invite nil, "about #{ em name.to_slug } help for #{
          }a particular adapter."
        nil
      end
    end

    def with_adapter_cli_action tainted_a, func, otherwise # mutates tainted_a
      res = nil
      match = resolve_adapter tainted_a.shift, -> e do
        res = otherwise[ e ]
      end
      if match
        kls = match.item.resolve_cli_action_class tainted_a, -> e do
          res = otherwise[ e ]
        end
        if kls
          action = @adapter_action_cache.fetch( kls ) do |k|
            @adapter_action_cache[ k ] = k.new self
          end
          res = func[ action ]
        end
      end
      res
    end
  end
end
