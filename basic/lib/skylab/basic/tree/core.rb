module Skylab::Basic

  module Tree

    class << self

      def frugal_node
        Tree_::Mutable_::Frugal
      end

      def immutable_node
        Immutable_Node_
      end

      def lazy_via_enumeresque * internal_properties, & children_yielder_p
        Lazy_via_Enumeresque__.new internal_properties, children_yielder_p
      end

      def merge_destructively
        Tree_::Sessions_::Merge
      end

      def mutable_node
        Tree_::Mutable_
      end

      def unicode
        Tree_::Expression_Adapters__::Text::Glyph
      end

      def via sym, x, * x_a, & x_p

        p_x = Tree_::Input_Adapters__.const_get(
          Callback_::Name.via_variegated_symbol( sym ).as_const, false )

        if x_a.length.nonzero? || block_given?
          x_a.push :upstream_x, x
          p_x.call_via_iambic x_a, & x_p
        else
          p_x[ x ]
        end
      end
    end  # >>

    class Binary

      class << self

        def via_sorted_range_list a

          d = a.length
          if 1 == d
            Leaf__[ a.first ]
          else

            d_ = d / 2
            if 1 == d_
              left = Leaf__[ a.first ]
              right = if ( d % 2 ).zero?
                Leaf__[ a.last ]
              else
                via_sorted_range_list a[ 1, 2 ]
              end
            else
              left = via_sorted_range_list a[ 0, d_ ]
              right = if ( d % 2 ).zero?
                via_sorted_range_list a[ d_, d_ ]
              else
                via_sorted_range_list a[ d_, d + 1 ]
              end
            end

            Branch___.new left, right
          end
        end
      end  # >>

      class Branch___

        def initialize left, right

          @begin = left.begin
          @determiner = right.begin
          @left = left
          @right = right
        end

        attr_reader :begin

        def is_leaf
          false
        end

        def category_for d

          if @determiner > d
            @left.category_for d
          else
            @right.category_for d
          end
        end
      end

      Leaf__ = IDENTITY_  # etc
    end

  class Lazy_via_Enumeresque__

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
            Pooled_Leaf__.instance_session do |tl|
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

  class Immutable_Leaf  # :+#experimental

    def initialize slug
      @slug = slug
    end

    def new_with_slug x
      self.class.new x
    end

    def has_children
      false
    end

    attr_reader :slug
  end

  class Pooled_Leaf__

    Callback_::Memoization::Pool[ self ].
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

    class Algortihm_Node__

      attr_reader :children, :parent, :value_x

      def members
        [ :children, :parent, :value_x, :children_depth_first,
          :children_depth_first_via_args_hook, :to_child_stream ]
      end

      def children_depth_first & p
        if has_children
          _children_depth_first_when_nonzero_children p
        end
      end

      protected def _children_depth_first_when_nonzero_children p
        o = to_child_stream
        while cx = o.gets
          p[ cx ]
          if cx.has_children
            cx._children_depth_first_when_nonzero_children p
          end
        end
      end

      def children_depth_first_via_args_hook * x_a, & visit_p
        @children.each do |node|
          child_p = nil
          visit_p.call node, * x_a, -> p do
            child_p = p
          end
          if node.has_children
            x_a_ = child_p[]
            node.children_depth_first_via_args_hook( * x_a_, & visit_p )
          end
        end
        nil
      end

      def to_child_stream
        if has_children
          Callback_::Stream.via_nonsparse_array @children
        else
          Callback_::Stream.the_empty_stream
        end
      end
    end

    class Immutable_Node_ < Algortihm_Node__

      def initialize & p
        instance_exec( & p )
        freeze
      end

      def members
        [ :child_count, :has_children, * super ]
      end

      attr_reader :child_count

      def dup_mutable
        _dup_mutable nil
      end

      public def _dup_mutable parent
        me = self
        ( Mutable_Node_.new do
          @parent = parent
          @value_x = me.value_x
          if me.has_children
            cx_a = []
            o = me.to_child_stream
            while cx = o.gets
              cx_a.push cx._dup_mutable self
            end
            @children = cx_a
          else
            @children = nil
          end
        end )
      end

      def has_children
        @child_count.nonzero?
      end

      class << self
        def the_empty_tree
          @tet ||= new
        end
      end
    end

    class Mutable_Node_ < Algortihm_Node__

      def initialize & p
        instance_exec( & p )
      end

      attr_writer :value_x

      def has_children
        ! @children.nil?
      end

      def child_count
        if @children
          @children.length
        else
          0
        end
      end
    end

    Autoloader_[ Expression_Adapters__ = ::Module.new ]

    Tree_ = self
  end
end