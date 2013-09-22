module Skylab::TanMan

  module CLI::Actions::Graph::Remote::Actions

    MetaHell::Boxxy[ self ]

  end

  class CLI::Actions::Graph::Remote::Actions::Add < CLI::Action

    desc "adds a remote data { source | destination } to the graph (for syncing)"

    def process
      api_invoke [ :graph, :remote, :add ], @param_h
    end

  private

    def argument_syntax_for_method i
      if :process == i then argument_syntax else super end
    end

    def argument_syntax
      ARGUMENT_SYNTAX__
    end

    ARGUMENT_SYNTAX__ = Headless::CLI::Argument::Syntax.DSL do
      o :optional, :literal, 'node-names'
      alternation do
        series do
          o :required, :literal, 'script'
          o :required, :value, :script
        end
      end
    end
  end
end
