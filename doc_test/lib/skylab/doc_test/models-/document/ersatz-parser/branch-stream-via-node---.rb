module Skylab::DocTest

  module Models_::Document

    class ErsatzParser

      class BranchStream_via_Node___ < Common_::Actor::Monadic

        # maybe only while we wait for things to settle

        def initialize root_node
          @root_node = root_node
        end

        def execute

          st = @root_node.to_constituent_node_stream
          stack = [ st ]

          p = -> do
            begin
              o = st.gets
              if o
                if o.is_branch
                  st = o.to_constituent_node_stream
                  stack.push st
                  break
                end
                redo
              end
              if 1 == stack.length
                p = nil
                break
              end
              stack.pop
              st = stack.fetch( -1 )
              redo
            end while nil
            o
          end

          Common_.stream do
            p[]
          end
        end
      end
    end
  end
end
