module Skylab::TanMan

  module API::Action::Parameter_Adapter

    def self.extended klass # [#sl-111]
      klass.extend Headless::Parameter::Definer # at [#045] (this and below)
      Headless::Parameter[ klass, :parameter_controller, :oldschool_parameter_error_structure_handler ]
    end
  end
end
