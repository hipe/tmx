module Skylab::Basic

  module Tree

    # ordinary trees are well-trodden and boring. we will find a way
    # to goof this one up somehow..

    def self.new *a, &b

      Tree::Via::Enumerator.new a, b

    end
  end

  module Tree::Via

  end

  class Tree::Via::Enumerator

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
      define_method :initialize do |a, f|
        instance_exec( *a, & h.fetch( a.length ) )
        @f = f
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
            Tree::Leaf.with_instance do |tl|
              tl.init_from_pool x
              y << tl
            end
          end
          nil
        end
        @f[ yld ]
      end
    end

    def is_leaf
      false
    end

    def data
      @local_x
    end
  end

  class Tree::Leaf

    Basic_::Lib_::Pool[ self ].with_with_instance

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
end
