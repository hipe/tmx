module Skylab::TMX

  class Magnetics_::GroupTree_via_ParsedNodeStream_and_Reductions < Common_::Actor::Dyadic

    def initialize st, a
      @parsed_node_stream = st
      @reductions = a
    end

    # the subject magnetic results in a "group tree", which is a structure
    # designed to represent orderings of items where the various attribute
    # values per attribute being sorted on are possibly non-unique; and
    # where an arbitrary number of "orderings" can be provided so that sub-
    # groups in the result set are themselves sorted, recursively.
    #
    # for example: if your entity is "name" and your attributes are
    # "first name", "middle name", and "last name"; you may want to do a
    # sort by last name, then (when last names are the same) first name,
    # then (when first names are ALSO the same) middle name. (and note that
    # even when all three are the same, there might be multiple entities
    # (people) with these same three names.)
    #
    #    +-------+        +-------+
    #    | group |-------O| group |
    #    |  tree |        +-------+
    #    +-------+            |
    #        |                |--[ lemma ]
    #        |                |
    #        |                | +------+
    #        +--------------> +-| list |
    #                           +------+
    #                              ^
    #                              |
    #                           +------+
    #                           | item |
    #                           | list |
    #                           +------+
    #
    # a "group tree" is composed of one or more "groups". a "group" is
    # a "list" representing the one or more items that have that "lemma"
    # in common.
    #
    # for example, imaging we are sorting by cost. the lemma would be the
    # particular cost, like `123`, an the items in the list would all have
    # this cost in common.
    #
    # in this model a "list" is actutually an abstract type: it can either
    # be an "item list" or a "group tree". in this manner we can a recursive,
    # arbitrarily deep tree of groups.

    def execute

      __init_several_things

      begin
        __process_the_current_reduction
      end while __there_is_another_reduction

      remove_instance_variable :@_group_tree
    end

    def __there_is_another_reduction
      if @_reduction_scanner.no_unparsed_exists
        remove_instance_variable :@_reduction_scanner
        UNABLE_
      else
        @_current_reduction = @_reduction_scanner.gets_one
        ACHIEVED_
      end
    end

    def __process_the_current_reduction

      # for each reduction, iterate over every "terminal list node" in the
      # structure and with each such list node, convert it to a node with
      # ONE more level of depth by converting it to ordered groups.

      # note we do this inefficiently where we are always navigating over
      # the terminal list nodes by holding a handle on the root node rather
      # than some wild cross-cutting linked-list thing on the tree. meh.

      redu = @_current_reduction

      st = @_group_tree._to_terminal_group_tree_stream
      begin
        gt = st.gets
        gt || break

        gt.__is_no_longer_deepest

        gt.groups.each do |group|

          item_list = group.list
          item_list.is_terminal || Here_._SANITY

          _pair_a = redu.group_list_via_item_list__ item_list.items

          _groups = _pair_a.map do |pair|
            # map from a generic type to our local custom type

            Group__.new ItemList__.new( pair.value_x ), pair.name_x
          end

          _group_tree = GroupTree__.new _groups

          group.list = _group_tree
        end
        redo
      end while above

      NIL
    end

    def __init_several_things

      @_reduction_scanner = Common_::Polymorphic_Stream.via_array @reductions
      @_current_reduction = @_reduction_scanner.gets_one

      _items = @parsed_node_stream.to_a
      _item_list = ItemList__.new _items
      _group = Group__.new _item_list
      @_group_tree = GroupTree__.new [ _group ]
      NIL
    end

    # ==

    class GroupTree__

      def initialize groups
        @_is_deepest = true
        @groups = groups
      end

      def __is_no_longer_deepest
        @_is_deepest = false
      end

      def to_node_stream
        if @_is_deepest
          Stream_[ @groups ].expand_by do |group|
            Stream_[ group.list.items ]
          end
        else
          Stream_[ @groups ].expand_by do |group|
            group.list.to_node_stream
          end
        end
      end

      def _to_terminal_group_tree_stream
        if @_is_deepest
          Common_::Stream.via_item self
        else
          Stream_[ @groups ].expand_by do |group|
            group.list._to_terminal_group_tree_stream
          end
        end
      end

      attr_reader(
        :groups,
      )

      def is_terminal
        false
      end
    end

    Group__ = ::Struct.new :list, :value_x

    ItemList__ = ::Struct.new :items do

      def is_terminal
        true
      end
    end

    # ==
  end
end
