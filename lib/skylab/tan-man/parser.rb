module Skylab::TanMan

  module Parser
  end

  module Parser::InstanceMethods
    include TanMan::Core::SubClient::InstanceMethods
    include Headless::Services::TreetopTools::Parser::InstanceMethods

    attr_accessor :on_load_parser_info # used usu. in tests to customize UI
  end
end
