module Skylab::DocTest

  class TestDocumentReadMagnetics_::BranchStream_via_BranchNode

        # the name, function and interface of this is in flux while things settle

        class << self

          def begin_for__ root_node
            new( root_node ).__init
          end

          private :new
        end  # >>

        def initialize root_node
          @root_node = root_node
        end

        def __init

          fr = Frame__.new @root_node
          @_stack = [ fr ]
          st = fr.constituent_node_stream

          p = -> do
            begin
              o = st.gets
              if o
                if o.is_branch
                  fr = Frame__.new o
                  st = fr.constituent_node_stream
                  @_stack.push fr
                  break
                end
                redo
              end
              if 1 == @_stack.length
                p = nil
                break
              end
              @_stack.pop
              st = @_stack.fetch( -1 ).constituent_node_stream
              redo
            end while nil
            o
          end

          @branch_stream = Common_.stream do
            p[]
          end

          self
        end

        def current_parent_branch__
          @_stack.fetch( -2 ).branch
        end

        attr_reader(
          :branch_stream,
        )

        # ==

        class Frame__

          def initialize branch
            @branch = branch
            @constituent_node_stream = branch.to_constituent_node_stream
          end

          attr_reader(
            :branch,
            :constituent_node_stream,
          )
        end
  end
end
