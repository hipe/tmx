module Skylab::SubTree::TestSupport::Models_Tree

  # ->

    module Paths_via_tree

      class << self
        def to_proc
          PROC___
        end
      end  # >>

      PROC___ = -> root_node do

        sep = root_node.path_separator

        p = nil
        visit = nil
        recurse = -> node, prefix_path, next_p do

          p = -> do

            st = node.to_child_stream

            p = -> do

              node_ = st.gets
              if node_

                visit[ node_, prefix_path, p ]
                p[]
              else
                p = next_p
                p[]
              end
            end
            p[]
          end
          nil
        end

        recurse[ root_node, nil, EMPTY_P_ ]

        visit = -> node, prefix_path, next_p do

          p = -> do

            has = node.has_children

            x = if node.has_slug

              if has
                s = sep
              end

              if prefix_path
                "#{ prefix_path }#{ node.slug }#{ s }"
              else
                "#{ node.slug }#{ s }"
              end
            else
              prefix_path  # any
            end

            if has
              recurse[ node, x, next_p ]

            else
              p = next_p
            end

            x
          end
          nil
        end

        Callback_.stream do
          p[]
        end.to_a
      end
    end

    # <-
end
