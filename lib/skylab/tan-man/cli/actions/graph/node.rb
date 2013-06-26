module Skylab::TanMan

  module CLI::Actions::Graph::Node::Actions

    MetaHell::Boxxy[ self ]

  end

  class CLI::Actions::Graph::Node::Actions::Add < CLI::Action

    desc "add a node (without associating it with another node)"

    inflection.inflect.noun :singular

    option_parser do |o|
      dry_run_option o
      o.on '-f', '--force', 'required to overcome fuzzy match dupe check.' do
        param_h[:force] = true
      end
      help_option o
      verbose_option o
    end

    def process name
      api_invoke( { dry_run: false, force: false, name: name, verbose: false }.
                 merge param_h )
    end
  end

  class CLI::Actions::Graph::Node::Actions::List < CLI::Action

    desc "list nodes in the graph"

    inflection.inflect.noun :plural

    option_parser do |o|
      verbose_option o
    end

    def process
      api_invoke( { verbose: false }.merge param_h )
    end
  end

  class CLI::Actions::Graph::Node::Actions::Rm < CLI::Action

    desc "destroys the node and all its associations!"

    inflection.inflect.noun :singular

    option_parser do |o|
      dry_run_option o
      help_option o
      verbose_option o
    end

    def process name
      api_invoke( { dry_run: false, node_ref: name, verbose: false }.
                 merge param_h )
    end
  end
end
