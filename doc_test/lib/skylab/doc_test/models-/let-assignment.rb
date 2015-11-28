module Skylab::TestSupport

  module DocTest

    module Intermediate_Streams_

      class Models_::Let_Assignment

        class << self

          def match line
            RX__.match line
          end

          alias_method :build, :new
        end

        RX__ = %r(\A
          [[:space:]]*
          (?<varname> [a-z_] [a-z_A-Z0-9]* )
          [[:space:]]+
          =
          [[:space:]]*
          (?<rhs>[^\n]+)
          \n?
          \z)x


        def initialize md
          @variable_name, @rhs = md.captures
        end

        attr_reader :rhs, :variable_name

        def members
          [ :variable_name, :rhs, :node_symbol ]
        end

        def node_symbol_when_context
          node_symbol
        end

        def node_symbol
          :let_assignment
        end
      end
    end
  end
end
