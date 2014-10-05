module Skylab::TanMan
  class Models::Starter::Collection
    include Core::SubClient::InstanceMethods

    CONFIG_PARAM = 'using_starter'

    def using_starter_metadata resource_name, success
      ok = nil
      begin
        meta = controllers.config.value_meta CONFIG_PARAM, resource_name
        meta or break
        success[ meta ]
        ok = true
      end while nil
      ok
    end

    def using_starter
      starter = nil
      begin
        value = nil
        b = using_starter_metadata :all, -> m { value = m.value }
        b or break
        value ||= API.default_starter_file
        starter = services.starters.fetch value # could throw if etc
      end while nil
      starter
    end

    attr_accessor :verbose # compat
  end
end
