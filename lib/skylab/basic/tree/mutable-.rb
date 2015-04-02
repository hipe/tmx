module Skylab::Basic

  module Tree

    class Mutable_ < Callback_::Box  # :+#final

      # experiment: a mutable tree based on "box".

      def initialize slug=nil

        super()
        @slug = slug
      end

      # ~ readers as parent

      def to_classified_stream_for modality_symbol, * x_a

        x_a.push :node, self

        s = modality_symbol.id2name  # :+#actor-case

        Tree_::Expression_Adapters__.const_get(

          :"#{ s[ 0 ].upcase }#{ s[ 1 .. -1 ] }", false

        )::Actors::Build_classified_stream.call_via_iambic x_a
      end

      def to_classified_stream

        Tree_::Actors__::Build_classified_stream.new( self ).execute
      end

      def longest_common_base_path

        node = any_only_child
        if node
          y = [ node.slug ]
          node.__longest_common_base_path_into y
          y
        end
      end

      def __longest_common_base_path_into y

        node = any_only_child
        if node
          y.push node.slug
          node.__longest_common_base_path_into y
        end
        NIL_
      end

      def fetch_node path_x, & else_p  # #todo covered only by [gv]

        me = self

        Tree_::Actors__::Fetch_or_touch.new do
          @path_x = path_x
          @x_p = else_p
          @node = me
          @fetch_or_touch = :fetch

        end.execute
      end

      def any_only_child

        fetch_only_child do end
      end

      def fetch_only_child

        if 1 == children_count
          fetch_first_child

        elsif block_given?
          yield

        else
          raise ::KeyError, __say_not_exactly_one_child
        end
      end

      def __say_not_exactly_one_child
        "expected 1, had #{ children_count } items"
      end

      def fetch_first_child
        child_at_position 0
      end

      def has_children
        children_count.nonzero?
      end

      alias_method :is_branch, :has_children

      def is_leaf
        children_count.zero?
      end

      alias_method :child_at_position, :fetch_at_position

      alias_method :to_child_stream, :to_value_stream

      alias_method :children_count, :length

      # ~ mutators as parent

      def merge_destructively otr

        Tree_::Sessions_::Merge.new( otr, self ).execute
      end

      def to_constituents  # #hook-out for above

        Tree_::Sessions_::Merge::Constituents.via_ivars self, :@node_payload
      end

      def to_destructee_polymorphic_key_stream  # ditto

        # because this object *will* be modified mid-scan,
        # we *must* use a duplicate array below.

        Callback_::Polymorphic_Stream.via_array @a.dup
      end

      def touch_node path_x, * x_a, & node_payload_p

        me = self
        ok = nil
        o = Tree_::Actors__::Fetch_or_touch.new do
          @path_x = path_x
          @x_p = node_payload_p
          @node = me
          @fetch_or_touch = :touch
          ok = if x_a.length.zero?
            ACHIEVED_
          else
            process_iambic_fully x_a
          end
        end
        ok && o.execute
      end

      def path_separator  # #hook-out for above
        ::File::SEPARATOR
      end

      # ~ readers as data node

      attr_reader :node_payload, :slug

      # ~ mutators as data node

      def set_node_payload x
        @node_payload = x
        NIL_
      end
    end
  end
end
