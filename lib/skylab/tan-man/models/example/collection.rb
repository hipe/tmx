module Skylab::TanMan
  class Models::Example::Collection
    include Core::SubClient::InstanceMethods

    CONFIG_PARAM = 'using_example'

    def using_example_metadata resource_name, success
      ok = nil
      begin
        meta = controllers.config.value_meta CONFIG_PARAM, resource_name
        meta or break
        success[ meta ]
        ok = true
      end while nil
      ok
    end

    def using_example
      example = nil
      begin
        value = nil
        b = using_example_metadata :all, -> m { value = m.value }
        b or break
        value ||= API.default_example_file
        example = services.examples.fetch value # could throw if etc
      end while nil
      example
    end
  end
end
