module Skylab::Basic

  module Tree  # :[#001].

    class << self

      def via sym, x, * x_a, & x_p

        _ = :"Tree_via_#{ Common_::Name.via_variegated_symbol( sym ).as_camelcase_const_string }"

        mag = Here_::Magnetics.const_get _, false

        if x_a.length.nonzero? || block_given?
          x_a.push :upstream_x, x
          mag.call_via_iambic x_a, & x_p
        else
          mag[ x ]
        end
      end
    end  # >>

    # ==

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

    # ==
    # ==

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

    # ==

    class Algortihm_Node__

      attr_reader :children, :parent, :value

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
          Common_::Stream.via_nonsparse_array @children
        else
          Common_::THE_EMPTY_STREAM
        end
      end
    end

    # ==

    class ImmutableNode < Algortihm_Node__

      def initialize & p
        instance_exec( & p )
        freeze
      end

      attr_reader :children_count

      def dup_mutable
        _dup_mutable nil
      end

      public def _dup_mutable parent
        me = self
        ( Mutable_Node_.new do
          @parent = parent
          @value = me.value
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
        @children_count.nonzero?
      end

      class << self
        def the_empty_tree
          @tet ||= new
        end
      end
    end

    # ==

    class Mutable_Node_ < Algortihm_Node__

      def initialize & p
        instance_exec( & p )
      end

      attr_writer :value

      def has_children
        ! @children.nil?
      end

      def children_count
        if @children
          @children.length
        else
          0
        end
      end
    end

    # ==

    module Magnetics

      # (experimental stowaways here and then there)

      Autoloader_[ self ]

      lazily :PathStream_via_Tree do
        self::PreOrderNormalPathStream_via_Tree
      end
    end

    # ==
    # ==

    Here_ = self
  end
end
# #history-A: moved feature island "lazy via enumeresque" to own file
