module Skylab::Headless
  module CLI::Client::DSL
    def self.extended mod # [#sl-111]
      mod.extend CLI::Box::DSL::ModuleMethods  # #reach-up!
      mod.send :include, CLI::Client::DSL::InstanceMethods
      mod._autoloader_init caller[0]  # extensive note about this in box/dsl.rb
      nil
    end
  end

  module CLI::Client::DSL::InstanceMethods
    include CLI::Client::InstanceMethods
    include CLI::Box::DSL::InstanceMethods
  end
end
