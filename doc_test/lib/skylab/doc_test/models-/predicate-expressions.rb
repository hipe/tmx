module Skylab::DocTest

  module Models_::Predicate_Expressions
    # -
      # -
        class << self

          def match line
            RX__.match line
          end

          def expression_via_matchdata md
            pre = md.pre_match
            post = md.post_match
            post.chomp!
            Fat_Comma_Proto_Predicate__.new pre, post
          end
        end

        RX__ = /[[:space:]]*#[ ]?=>[[:space:]]*/

        class Raw_Line
          class << self
            alias_method :[], :new
          end

          def initialize s
            @chomped_line = s.chomp  # don't mutate the received string, it's not yours
          end

          attr_reader :chomped_line

          def members
            [ :chomped_line, :expression_symbol ]
          end

          def expression_symbol
            :raw_line
          end

          ( BLANK_LINE = new NEWLINE_ ).chomped_line.freeze
        end

        class Fat_Comma_Proto_Predicate__

          def initialize * a
            @lhs, @rhs = a
          end

          attr_reader :lhs, :rhs

          def members
            [ :lhs, :rhs, :expression_symbol ]
          end

          def expression_symbol
            :proto_predicate
          end
        end
      # -
    # -
  end
end
