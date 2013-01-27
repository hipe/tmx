module Skylab::Treemap
  module API::Action::AdapterInstanceMethods # [#024] - move adapter instance ..
    include Treemap::Core::SubClient::InstanceMethods

  protected
                                  # result values are very important and fixed:
                                  # false if failure
                                  # nil if no change (to adapter, not name)
                                  # else adapter instance (it changed)
    def activate_adapter_if_necessary name, error
      res = set_adapter_name name, error
      if false != res
        before = adapter_box.hot_instance_ivar
        if ! ( before && res.nil? ) # assume this means correct is already set
          res or fail 'sanity' # it's not nil and and it's not false so
          if ! adapter_box.hot_class_ivar
            res = adapter_box.load_hot_class error
          end
          res &&= adapter_box.hot_instance
        end
      end
      res
    end

    def adapter_box
      @adapter_box ||= api_client.adapter_box
    end
                                  # if you don't have this, then defaulting
                                  # logic will change the active adapter
    def adapter_name              # from one that you selected! (because
      adapter_box.hot_name        # the parad definer creates a reader
    end                           # for you! ouch!)


    def adapter_name= name
      set_adapter_name name, -> e do
        add_validation_error_for :adapter_name,
          "failed to load {{adapter_name}}: adapter #{ e }",
            adapter_name: name
        end
      name
    end

    def set_adapter_name name, error=nil       # res false, nil, or name
      res = false
      found, a = adapter_box.fuzzy_match_name name
      case found.length
      when 0
        # i bet you wish you had headless sub-client [#010]
        err = "not found. #{ s a, :no }known adapter#{ s a } #{ s a, :is } #{
                }#{ and_ a.map { |x| pre x } }".strip
      when 1
        res = adapter_box.set_hot_name found.first # nil or name
      else
        err = "is ambiguous -- did you mean #{ or_ found.map { |x| pre x } }?"
      end
      if false == res
        error ||= -> e { self.error e }
        error[ "adapter #{ pre name } #{ err }" ]
      end
      res
    end
  end
end
