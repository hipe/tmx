module Skylab::Snag
  module CLI::Actions
  end

  class CLI::Actions::Node < CLI::Action::Box
  end

  class CLI::Actions::Node::Actions::Tags < CLI::Action::Box
    extend Headless::CLI::Box::DSL

    desc 'add a tag to a node.'

    option_parser do |o|
      dry_run_option o
      verbose_option o
    end

    def add node_ref, tag_name
      api_invoke [:node, :tags, :add],
        { dry_run: false, node_ref: node_ref, tag_name: tag_name,
          verbose: false }.merge( param_h )
    end
  end
end
