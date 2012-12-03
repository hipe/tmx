module Skylab::TanMan


  module Parser
  end


  module Parser::InstanceMethods
    include TreetopTools::Parser::InstanceMethods

    attr_accessor :on_load_parser_info # used usu. in tests to customize UI

    define_method :pretty_path_hack, & Face::PathTools::FUN.pretty_path_hack

  end
end
