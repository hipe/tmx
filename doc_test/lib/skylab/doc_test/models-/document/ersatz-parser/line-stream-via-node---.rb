module Skylab::DocTest

  module Models_::Document

    class ErsatzParser

      class LineStream_via_Node___ < Common_::Actor::Monadic

        # (as we've done many times before)

        def initialize root_node
          @root_node = root_node
        end

        def execute

          st = @root_node.to_node_stream
          stack = [ st ]

          p = -> do
            o = st.gets
            if o
              if o.is_branch
                st = o.to_node_stream
                stack.push st
                p[]
              else
                o.line_string
              end
            elsif 1 == stack.length
              p = nil
              NOTHING_
            else
              stack.pop
              st = stack.fetch( -1 )
              p[]
            end
          end

          Common_.stream do
            p[]
          end
        end
      end
    end
  end
end
