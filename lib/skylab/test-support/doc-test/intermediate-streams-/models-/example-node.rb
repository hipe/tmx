module Skylab::TestSupport

  module DocTest

    module Intermediate_Streams_

      class Models_::Example_Node

        class << self
          alias_method :build, :new
        end

        def initialize * a
          text_span, md = a
          @description_s = Models_::Description_String[ text_span.a.last ]
          @expressiona_a = md.flush_to_expression_list
        end

        def members
          [ :description_string, :to_child_stream, :node_symbol ]
        end

        def node_symbol
          :example_node
        end

        def description_string
          @description_s
        end

        def to_child_stream
          Callback_.stream.via_nonsparse_array @expression_a
        end

        class Matchdata
          def initialize * a
            @md, @lines, @span = a
          end

          def is_ancillary_nodes
            false
          end

          def flush_to_expression_list

            @line_count = 0
            @line = @lines.gets
            a = []
            while @line
              @line_count += 1
              if BLANK_RX_ =~ @line
                @line = @lines.gets
                next
              end
              md = Models_::Predicate_Expressions.match @line
              if md
                a.push bld_predicate_expression md
              else
                a.push bld_raw_expression @line
              end
              @line = @lines.gets
            end
            @lines = nil

            if @md
              a.push bld_predicate_expression @md
            end

            a
          end

          def bld_raw_expression line
            Models_::Predicate_Expressions::Raw_Line[ line ]
          end

          def bld_predicate_expression md
            Models_::Predicate_Expressions.expression_via_matchdata md
          end
        end
      end
    end
  end
end
