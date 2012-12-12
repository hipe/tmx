module Skylab::TanMan

  class Models::Examples::Controller

    include Core::SubClient::InstanceMethods

    def selected_status resource_name, success
      ok = nil
      begin
        meta = controllers.config.value_meta :example, resource_name
        meta or break
        success[ meta ]
        ok = true
      end while nil
      ok
    end

    def use_template
      template = nil
      begin
        value = nil
        b = selected_status :all, -> m { value = m.value }
        b or break
        value ||= 'digraph.dot'
        template = services.examples.fetch value # could throw if etc
      end while nil
      template
    end
  end
end
