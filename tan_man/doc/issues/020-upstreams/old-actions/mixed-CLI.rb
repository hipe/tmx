module Skylab::TanMan

  module CLI::Actions::Graph::Remote::Actions
    # #was-boxxy
  end

  class CLI::Actions::Graph::Remote::Actions::Add < CLI::Action

    desc "adds a remote data { source | destination } to the graph (for syncing)"

    def process
      api_invoke [ :graph, :remote, :add ], @param_h
    end

  private

    def argument_syntax_for_action_i i
      if :process == i then argument_syntax else super end
    end

    def argument_syntax
      ARGUMENT_SYNTAX__
    end

    ARGUMENT_SYNTAX__ = LIB_.CLI_lib.argument.syntax.DSL do
      o :optional, :literal, 'node-names'
      alternation do
        series do
          o :required, :literal, 'script'
          o :required, :value, :script
        end
      end
    end
  end

  class CLI::Actions::Graph::Remote::Actions::List < CLI::Action

    TanMan::Sub_Client[ self, :expression_agent ]

    desc "list the known remotes for this graph"

    def process
      begin
        r = scn = api_invoke or break
        if ! (( first = scn.gets ))
          emit :info, "there are no known remotes for this graph"
          break
        end
        _ea = ::Enumerator.new do |y|
          scn.rewind
          while (( remote = scn.gets )) ; y << remote.to_a.map( & :to_s ) end
          true  # a gotcha when using the table renderer
        end
        y = [ ] ; first.members.each do |i|
          y << :field << i.to_s.gsub( /\A[a-z]/, & :upcase ).gsub( '_', ' ' )
        end
        r = TanMan::Services::F_ace::CLI::Table[ * y,
          :left, '| ', :sep, ' | ', :right, ' |',
          :read_rows_from, _ea,
          :write_lines_to, method( :payload ) ]
        help_yielder << ( expression_agent.calculate do
          "#{ scn.count } remote#{ s scn.count } total."
        end )
      end while nil
      r
    end

    class CLI::Actions::Graph::Remote::Actions::Remove < CLI::Action

      desc "remove that remote"

      option_parser do |o|
        dry_run_option o
        help_option o
      end

      def process locator
        api_invoke @param_h.merge( locator: locator )
      end
    end
  end
end
