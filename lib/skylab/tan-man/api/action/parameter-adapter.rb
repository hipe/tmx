module Skylab::TanMan

  module API::Action::Parameter_Adapter

    def self.extended klass # [#sl-111]
      klass.extend Headless::Parameter::Definer # at [#045] (this and below)
      klass.send :include, Headless::Parameter::Controller::InstanceMethods
    end
  end
end
