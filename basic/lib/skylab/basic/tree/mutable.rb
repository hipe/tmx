module Skylab::Basic

  module Tree

    class Mutable < Common_::Box

      # experiment: a mutable tree based on "box".

      def initialize slug=nil

        super()
        @slug = slug
      end

      def change_slug s
        @slug = s
        NIL_
      end

      # -- As parent --

      # ~ mutators (newer)

      def accept & visit  # visitor pattern experiment

        visit[ self ]

        st = to_child_stream
        begin
          x = st.gets
          x or break
          _yes = x.has_children
          _yes or redo
          x.accept( & visit )
          redo
        end while nil

        NIL_
      end

      # ~ readers

      def winnow path_s  # find closest match. result is that node plus scan

        # (we don't *think* this is related to [#001.2] "winnow" algorithm)

        wahoo_p = -> node, st do
          [ st, node ]
        end

        x = Here_::Node_via_Fetch_or_Touch_.new self do

          @fetch_or_touch = :fetch
          @path_x = path_s
          @result_tuple_proc = wahoo_p
          @when_not_found = wahoo_p

        end.execute

        if ! x
          self._SANITY
        end
        x
      end

      # ~ we used to do string math but it's counter-productive (#tombstone-A)

      def to_stream_of moda_sym, * x_a

        :paths == moda_sym || self._WHERE

        x_a.push :node, self

        Here_::Magnetics::PathStream_via_Tree.call_via_iambic x_a
      end

      def to_pre_order_normal_path_stream

        Here_::Magnetics::PreOrderNormalPathStream_via_Tree[ self ]
      end

      def to_classified_stream_for moda_sym, * x_a

        :text == moda_sym || self._WHERE

        x_a.push :node, self

        Here_::Magnetics::ClassifiedStream_via_Tree_for_Text.call_via_iambic x_a
      end

      def to_classified_stream
        Here_::Magnetics::ClassifiedStream_via_Tree[ self ]
      end

      # ~

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

        Here_::Node_via_Fetch_or_Touch_.new self do
          @fetch_or_touch = :fetch
          @path_x = path_x
          @when_not_found = else_p

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

      alias_method :child_at_position, :at_offset

      alias_method :to_child_stream, :to_value_stream

      alias_method :children_count, :length

      # ~ mutators (placement in file is legacy placement)

      def merge_destructively otr

        _merge_lib.new( otr, self ).execute
      end

      def to_constituents  # #hook-out for above

        _merge_lib::Constituents.via_ivars self, :@node_payload
      end

      def _merge_lib
        Here_::Magnetics::MergedTree_via_Trees
      end

      def to_destructee_key_scanner  # ditto

        # because this object *will* be modified mid-scan,
        # we *must* use a duplicate array below.

        Common_::Scanner.via_array @a.dup
      end

      def touch_node path_x, * x_a, & node_payload_p

        o = Here_::Node_via_Fetch_or_Touch_.new self do
          @path_x = path_x
          @node_payload_proc = node_payload_p
          @fetch_or_touch = :touch
        end

        ok = if x_a.length.zero?
          ACHIEVED_
        else
          o.process_iambic_fully x_a
        end

        if ok
          o.execute
        else
          ok
        end
      end

      def path_separator  # #hook-out for above
        ::File::SEPARATOR
      end

      # -- As data node --

      # ~ mutators

      def set_node_payload x
        @node_payload = x
        NIL_
      end

      class Frugal < self  # as-is (not complete), for [sg] (now [cm] too)

        def initialize slug=nil
          @a = nil
          @slug = slug
        end

        def children_count
          if @a
            super
          else
            0
          end
        end

        def touch i, & p
          @a or _!
          super
        end

        def _!
          @a = []
          @h = {}
          NIL_
        end
      end

      # ~ readers

      attr_reader(
        :node_payload,
        :slug,
      )
    end
  end
end
# :#tombstone-A: string math
