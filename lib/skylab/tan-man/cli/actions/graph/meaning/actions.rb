module Skylab::TanMan
  module CLI::Actions::Graph::Meaning::Actions
    extend MetaHell::Boxxy
  end


  class CLI::Actions::Graph::Meaning::Actions::List < CLI::Action
    option_parser do |o|
      help_option o
      verbose_option o
    end
    def process
      api_invoke [:graph, :meaning, :list], param_h
    end
  end


  class CLI::Actions::Graph::Meaning::Actions::Add < CLI::Action
    option_parser do |o|
      help_option o
      verbose_option o
    end
    def process name, value
      api_invoke [:graph, :meaning, :learn],
        param_h.merge( name: name, value: value, create: true )
    end
  end


  class CLI::Actions::Graph::Meaning::Actions::Change < CLI::Action
    option_parser do |o|
      help_option o
      verbose_option o
    end
    def process name, value
      api_invoke [:graph, :meaning, :learn],
        param_h.merge( name: name, value: value, create: false )
    end
  end


  class CLI::Actions::Graph::Meaning::Actions::Forget < CLI::Action
    option_parser do |o|
      help_option o
      verbose_option o
    end
    def process name
      api_invoke [:graph, :meaning, :forget],
        param_h.merge( name: name )
    end
  end
end
