module Skylab::Basic

  module Tree

    class Magnetics::Tree_via_DefinitionEvaluatedLazily

      # #feature-island. kept here to have more options, for now. see #history-A

      # -
        -> do  # `initialize`
          h = {
            0 => -> do
              @has_local_data = false
            end,
            1 => -> x do
              @has_local_data = true
              @local_x = x
            end
          }
          define_method :initialize do |p, a|
            instance_exec( *a, & h.fetch( a.length ) )
            @__proc = p
          end
        end.call

        # `flatten` - you get no branch local data, only the data from
        # each leaf node recursive.

        def flatten
          ::Enumerator.new( & method( :flatten_ ) )
        end

        def flatten_ y
          children.each do |tree|
            if tree.is_leaf
              y << tree.leaf_data
            else
              tree.flatten_ y
            end
            # it is important that you propagate the result of child's `each` here.
          end
        end
        protected :flatten_  # #protected-not-private

        # `children` - each yielded item is always a node it is never
        # the local data or leaf data.

        def children
          ::Enumerator.new do |y|
            yld = ::Enumerator::Yielder.new do |x|
              if x.respond_to? :is_leaf
                y << x
              else
                PooledLeaf___.instance_session do |tl|
                  tl.init_from_pool x
                  y << tl
                end
              end
              nil
            end
            @__proc[ yld ]
          end
        end

        def data
          @local_x
        end

        def is_leaf
          false
        end
      # -

      # ==

      class PooledLeaf___

        Common_::Memoization::Pool[ self ].
          instances_can_only_be_accessed_through_instance_sessions

        def init_from_pool x
          @leaf_data = x
          nil
        end

        def clear_for_pool
          @leaf_data = nil
        end

        def is_leaf
          true
        end

        def leaf_data
          @leaf_data  # etc
        end
      end

      # ==
      # ==
    end
  end
end
# #history-A: broke stowaway out. code is older than file.
