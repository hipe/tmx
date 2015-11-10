module Skylab::Basic

  module Tree

    module Expression_Adapters__::Paths

      module Actors

        class Build_stream

          Callback_::Actor.call( self, :properties,
            :do_branches,
            :node,
          )

          def initialize
            @do_branches = true
            super
          end

          def execute

            To_path_stream___[ @node, @do_branches ]
          end
        end
      end

      To_path_stream___ = -> root_node, do_branches do

        sep = root_node.path_separator

        join = -> pp, s do
          if pp
            if s
              "#{ pp }#{ sep }#{ s }"
            else
              pp
            end
          else
            s
          end
        end

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

        visit_when_do_branches = -> node, prefix_path, next_p do

          p = -> do

            has = node.has_children

            slug = node.slug

            x = if slug

              if has
                s = sep
              end

              if prefix_path
                "#{ prefix_path }#{ slug }#{ s }"
              else
                "#{ slug }#{ s }"
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

        # -- No branches (only)

        visit_when_not_do_branches = -> node, path, next_p do

          p = -> do

            st = node.to_child_stream
            p = -> do

              node_ = st.gets
              if node_
                path_ = join[ path, node_.slug ]

                if node_.has_children

                  visit[ node_, path_, p ]
                  p[]
                else
                  path_
                end
              else
                p = next_p
                p[]
              end
            end
            p[]
          end
        end

        # --

        if do_branches
          visit = visit_when_do_branches
        else
          visit = visit_when_not_do_branches
          p = -> do
            visit[ root_node, root_node.slug, EMPTY_P_ ]
            p[]
          end
        end

        Callback_.stream do
          p[]
        end
      end
    end
  end
end
