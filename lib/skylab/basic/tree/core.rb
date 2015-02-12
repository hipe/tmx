module Skylab::Basic

  module Tree

    # ordinary trees are well-trodden and boring. we will find a way
    # to goof this one up somehow..

    class << self

      def immutable_node
        Immutable_Node_
      end

      def lazy_via_enumeresque * internal_properties, & children_yielder_p
        Lazy_via_Enumeresque__.new internal_properties, children_yielder_p
      end

      def via * i_a
        Via__.call_via_iambic i_a
      end
    end

    class Via__

      Callback_::Actor.methodic self, :simple, :properties,
        :property, :build_using,
        :property, :glyph,
        :iambic_writer_method_to_be_provided, :property, :indented_line_stream,
        :property, :on_event_selectively

      def initialize
        @build_using = nil
        super
      end

      def execute
        send @execute_method_name
      end

    private

      def indented_line_stream=
        @execute_method_name = :execute_via_indented_line_stream
        @stream = iambic_property
        ACHIEVED_
      end

      def execute_via_indented_line_stream
        Tree_::Via_Indented_Line_Stream__.new( @build_using, @stream,
          @glyph, @on_event_selectively ).execute
      end
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
            Pooled_Leaf__.with_instance do |tl|
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

  class Pooled_Leaf__

    Basic_.lib_.pool( self ).with_with_instance

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


    Tree_ = self
  end
end
