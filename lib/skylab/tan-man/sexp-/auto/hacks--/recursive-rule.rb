module Skylab::TanMan

  module Sexp_::Auto

  module Hacks__::RecursiveRule

    # Synopsis: this hack exists primarily to deliver the list mutation API,
    # a sub-library that is both essential to the host application and (in its
    # implementation) highly experimental in effort to DRY itself.
    #
    #
    # Behavior added by this hack:
    #
    # for any structure class that matches any first of the below criteria,
    # it will be given (directly) a set of methods which whenever appropriate
    # will have a name and behavior that is an adaption of a particular
    # function from the W3C's XML DOM API: `insertBefore`, `appendChild`,
    # `removeChild`.
    #
    # in this documentation and code we will refer to these added methods
    # generally as "operations".
    #
    # these operations should behave generally in the expected way, with
    # (open [#092]) either some magic or some specialization to be added
    # to allow for strings to be passed in instead of nodes when relevant.
    #
    # when relevant the W3C names will be adapted in some regular way,
    # probably to substitue our idiomatic "node" in place of "child", and to
    # give the methods more self-documenting names with respect to their
    # parameters.
    #
    #
    # Criteria to match the hack:
    #
    # remember that our parses produce structures that follow the name and
    # structure of the rules of the grammar. this hack matches those structure
    # classes that match any first of this series of patterns:
    #
    # 1) if the structure class has a member that is the same name as the
    #    structure class's corresponding rule (e.g if structure class `FooBar`
    #    (made for rule `foo_bar`) has a member `foo_bar`), then this
    #    structure class falls into the classification we call "simple
    #    recursion". in instances of this structure, this member "slot" (when
    #    occupied) is assumed to be another instance of this same class of
    #    structure.
    #
    # 2) if the structure class's corresponding rule is named something like
    #    `foo_list` *and* has a `foo` as an element (where `foo` is any
    #    nonzero length span of characters), then we assume there is also a
    #    member called `tail` which in turn (when occupied) is assumed to be
    #    occupied by an intermediate structure that itself has a member called
    #    `foo_list` which (when occupied) is again an instance of the topic
    #    structure class and so on. we call this classification "compound
    #    recursion".
    #
    #
    # Implementaion
    #
    # we implement all this with two categories of component: method
    # builders and "operation sessions". within each category of component
    # there is one base class and then one sub-class for each classification
    # of grammar, amounting to around 6 classes.

    extend Hack_::ModuleMethods

    class << self

      def match o

        builder_cls = if o.has_members_of_interest

          md = LIST_RX__.match o.rule.to_s
          if md
            stem_i = md[ :stem ].intern
          end

          moi = o.members_of_interest
          rule_i = o.rule

          if moi.include? rule_i  # a "foo" rule with a "foo" element
            Simple_Recursion_Methods_Builder___

          elsif stem_i and moi.include? stem_i
            Compound_Recursion_Methods_Builder___
          end
        end

        if builder_cls
          builder_cls.new( stem_i, moi, o.tree_class, rule_i ).__produce_hack
        end
      end
    end  # >>

    LIST_RX__ = Hack_.list_rx  # any name that ends in "_list"

    class Methods_Builder__

      def initialize stem_i, moi, cls, rule_i
        @cls = cls
        @rule_i = rule_i
        @stem_i = stem_i
        @some_stem_i = stem_i || rule_i
        init_session_prototype_
      end

      def __produce_hack
        Hack_.new do
          me = self
          @cls.class_exec do

            include Common_Static_Methods___

            # ~ mutators

            define_method :_append!, me.build_append_item_method
            define_method :_insert_item_before_item, me.build_insert_item_before_item_method
            define_method :_remove_item, me.build_remove_item_method

            # ~ readers

            define_method me.pluralized_method_name, ITEMS_SOFT_ALIAS_METHOD___
            define_method :_items, me.build_to_items_array_method  # #todo: rename this to `to_items_array_`
            define_method :to_node_stream_, me.build_to_node_stream_method

            nil
          end
        end
      end

      # ~ mutators

      def build_insert_item_before_item_method

        sess = @session
        -> new_x, before_this_x do
          before_this_x or self._WHERE
          o = sess.dup
          o.init_insertion to_node_stream_, new_x, self
          o.receive_reference_x before_this_x
          o.insert_new_item_before_item
        end
      end

      def build_append_item_method

        sess = @session
        -> new_s do
          o = sess.dup
          o.init_insertion to_node_stream_, new_s, self
          o.via_new_string_append
        end
      end

      def build_remove_item_method

        sess = @session
        -> s do
          o = sess.dup
          o.remove to_node_stream_, s, self
        end
      end

      # ~ for readers

      def pluralized_method_name
        :"#{ @some_stem_i }s"
      end

      def build_to_items_array_method
        item_k = @session.item_k
        -> do
          to_node_stream_.map_by do | x |
            x[ item_k ]
          end.to_a
        end
      end
    end

    ITEMS_SOFT_ALIAS_METHOD___ = -> do
      _items
    end

    class Simple_Recursion_Methods_Builder___ < Methods_Builder__

      def init_session_prototype_

        @session = Simple_Recursion_Operation_Session___.new(

          @some_stem_i,  # stem
          :content,  # item
          @rule_i ) # tail
        nil
      end

      def build_to_node_stream_method

        tail_k = @session.tail_k
        item_k = @session.item_k

        -> do
          p = nil
          main_p = -> do
            x = self
            p = -> do
              x = x[ tail_k ]
              if ! x
                p = EMPTY_P_
              end
              x
            end
            x
          end
          p = -> do
            # because #artificial-stub
            if self[ item_k ]
              p = main_p
              p[]
            else
              p = EMPTY_P_
              nil
            end
          end
          Callback_.stream do
            p[]
          end
        end
      end
    end

    class Compound_Recursion_Methods_Builder___ < Methods_Builder__

      def init_session_prototype_

        @session = Compound_Recursion_Operation_Session__.new(

          @stem_i,  # stem
          @stem_i,  # item
          :tail,  # tail
          @rule_i )  # list

        nil
      end

      def build_to_node_stream_method

        item_k = @session.item_k
        list_k = @session.list_k
        tail_k = @session.tail_k

        -> do
          p = nil
          main_p = -> do
            x = self
            p = -> do
              tail_x = x[ tail_k ]
              x_ = if tail_x
                tail_x[ list_k ]
              end
              if x_
                x = x_
                x_
              else
                p = EMPTY_P_
                nil
              end
            end
            self
          end
          p = -> do
            if self[ item_k ]
              p = main_p
              p[]
            else
              p = EMPTY_P_
              nil
            end
          end
          Callback_.stream do
            p[]
          end
        end
      end
    end

    class Operation_Session__

      # for those operations that mutate the list (append, insert, remove)
      # we implement each operation in its particular call with one session
      # instance. the session is used as a "scratch space" to hold operation-
      # specific data as needed which is then discarded when the operation is
      # complete; preserving the ivar namespace of the participating
      # structure itself. we achieve this by duping a "prototype" session
      # that starts with having nothing but the particular member names.

      def initialize stem, item, tail
        @item_k = item
        @stem_k = stem
        @tail_k = tail
      end

      attr_reader :item_k, :stem_k, :tail_k

      # ~ appendation & insertion

      def init_insertion node_st, new_x, front_node
        @front_node = front_node
        if new_x.respond_to? :ascii_only?
          @argument_is_string = true
          @new_s = new_x
        else
          @argument_is_string = false
          @new_x = new_x
        end
        @node_st = node_st
        nil
      end

      def via_new_string_append

        # exhaust the stream until you are left with any last two items:
        #   [ [ node_Y ] node_Z ]

        node_Y, node_Z = any_last_two_via_stream @node_st

        @new_item_x = _via_argument_produce_new_mixed_item

        if node_Z

          if node_Y
            __via_new_item_node_append_to_nodes_Y_and_Z node_Y, node_Z
          else
            __via_new_item_node_append_to_only_node node_Z
          end
        else
          via_new_item_node_append_into_starter_stub_
        end
      end

      def __via_new_item_node_append_to_nodes_Y_and_Z node_Y, node
        via_new_item_node_append_to_only_node_using_prototype_list_ node, node_Y
      end

      def __via_new_item_node_append_to_only_node node
        via_new_item_node_append_to_only_node_using_prototype_list_ node, _prototype_list
      end

      def insert_new_item_before_item  # assume the reference node exists

        # we care about whether or not the new node is being added at the
        # front and if so whether the existing list is only one item long

        p = _build_equality_comparator_proc
        st = @node_st
        x = st.gets

        if x

          if p[ x ]
            before_first_node = true
            any_second_node = st.gets
          else

            begin
              greatest_lesser = x
              x = st.gets
              x or break
              if p[ x ]
                before_non_first_node = true
                break
              end
              redo
            end while nil
          end
        end

        if before_non_first_node

          __build_and_insert_node_between_nodes_L_and_N greatest_lesser, x

        elsif any_second_node

          __build_and_insert_node_in_front_of_plural_list

        elsif before_first_node

          __build_and_insert_node_in_front_of_only_node

        else
          self._NOT_FOUND
        end
      end

      def __build_and_insert_node_between_nodes_L_and_N node_L, node_N

        # the styling of node M must express that it is both non-first and
        # non-last. node L is non-last and node N is non-first. so for now
        # we start with a dup of node L and then passively merge on top of
        # it node N before finally transfering the content member.

        _new_item_x = _via_argument_produce_new_mixed_item

        node_M = node_L.dup

        node_L.members.each do | k |
          if ! node_M[ k ]
            x = node_N[ k ]
            if x
              node_M[ k ] = x
            end
          end
        end

        node_M[ @tail_k ] = node_M[ @tail_k ].dup  # make it its own copy
        node_M[ @item_k ] = _new_item_x
        set_nodes_next_node_ node_L, node_M
        set_nodes_next_node_ node_M, node_N

        node_M
      end

      # the root node is the only node that cannot change identity. as such
      # to accomplish this operation we will: 1) make a "created node" that
      # is a shallow dup of the root node and 2) transfer the argument data
      # into the root node as appropriate and 3) point the root node to the
      # created node. any second node that was here when we got here (which
      # is now the third node) should automatically be OK during the above.

      def __build_and_insert_node_in_front_of_only_node

        # use :+#prototype-styling

        pl = _prototype_list
        if pl
          _via_root_node_insert_at_front do | created_node |
            _resolve_styling_for_front_insertion created_node, pl
          end
        else
          raise Prototype_Required.new( 1, :insert_into )
        end
      end

      def __build_and_insert_node_in_front_of_plural_list

        # use :+#proximity-styling

        _via_root_node_insert_at_front do | created_node |
          _resolve_styling_for_front_insertion created_node, @front_node
        end
      end

      def _via_root_node_insert_at_front

        root_node = @front_node

        _new_item_x = _via_argument_produce_new_mixed_item

        created_node = root_node.dup  # (1)

        root_node[ @item_k ] = _new_item_x  # (2)

        yield created_node  # resovle styling

        affix_to_prepared_node_P_node_Q_ root_node, created_node  # (3)

        root_node
      end

      def _resolve_styling_for_front_insertion created_node, proto_list

        # if the root node has a tail member, then it is the tail member that
        # the original root had. the `proto_list` may be the root node and it
        # may not. in the case that the root node had a tail member and there
        # is no true prototype, dup the member so we don't mutate that of the
        # created node. if the prototype is a true prototype, then we dup the
        # member from *there* assuming that is what we should be using anyway

        root_node = @front_node

        had_tail = root_node[ @tail_k ]

        root_node[ @tail_k ] = proto_list[ @tail_k ].dup  # must exist

        if ! had_tail

          # any members that aren't already set in the root node should be
          # "styled" to express a non-final node (for e.g we might need to
          # pick up a separator expression).

          proto_list.members.each do | k |
            if ! root_node[ k ]
              x = proto_list[ k ]
              if x
                root_node[ k ] = x.dup  # assmue string
              end
            end
          end
        end

        nil
      end

      def any_last_two_via_stream st
        node_Z = nil
        begin
          x = st.gets
          x or break
          node_Y = node_Z
          node_Z = x
          redo
        end while nil
        [ node_Y, node_Z ]
      end

      # ~ removal

      def remove st, reference_x, front_node

        @front_node = front_node

        receive_reference_x reference_x
        p = _build_equality_comparator_proc

        begin
          x = st.gets
          x or break
          if p[ x ]
            did_find = true
            break
          end
          prev = x
          redo
        end while nil

        if did_find
          x_ = st.gets
          if prev
            if x_
              remove_nonfinal_node_B_ prev, x, x_
            else
              remove_final_node_B_ prev, x
            end
          elsif x_
            remove_node_A_ x, x_
          else
            __remove_the_only_node
          end
        else
          self._DO_ME
        end
      end

      def __remove_the_only_node

        # amazingly this works for both grammar categories for now

        node = @front_node
        x = node[ @item_k ]
        node.members.each do | k |
          node[ k ] = nil
        end
        x
      end

      # ~ support

      # ~~ support for reference

      def receive_reference_x reference_x
        if reference_x.respond_to? :ascii_only?
          @reference_is_string = true
          @reference_s = reference_x
        else
          @reference_is_string = false
          @reference_item_x = reference_x
        end ; nil
      end

      def _build_equality_comparator_proc

        if @reference_is_string  # clean up in #open [#092]
          build_string_comparator_proc___
        else
          __build_normal_equality_comparator_proc
        end
      end

      def __build_normal_equality_comparator_proc
        oid = @reference_item_x.object_id
        -> x do
          oid == x[ @item_k ].object_id
        end
      end

      # ~~ support for node production

      def _via_argument_produce_new_mixed_item  # while #open [#092]

        if @argument_is_string
          produce_new_mixed_item_via_string_argument_
        else
          @new_x
        end
      end

      def _prototype_list
        @front_node._prototype
      end
    end

    class Simple_Recursion_Operation_Session___ < Operation_Session__

      # ~ appendation (the two #hook-out's)

      def via_new_item_node_append_into_starter_stub_
        front_node = @front_node
        front_node[ @item_k ] = @new_item_x
        front_node
      end

      def via_new_item_node_append_to_only_node_using_prototype_list_ node, pl

        # 1) style the new final node that we are creating to look like the
        # final node of the acting protoype (the easiest way is to dup it &
        # copy over the one content member). 2) point the old final node to
        # the new final node. 3) style the old final node appropriately now
        # that it is non-final.

        _last = pl.to_node_stream_.last  # (1)
        new_item_node = _last.dup
        new_item_node[ @item_k ] = @new_item_x

        node[ @tail_k ] = new_item_node  # (2)

        pl.members.each do | k |  # (3)

          if node[ k ]
            @item_k == k and next  # don't overwrite its content member
            @tail_k == k and next  # don't overwrite its next member
              # but separators, delimiters & whitespace re-style based
              # on the proto
          end

          x = pl[ k ]
          x or next  # we allow any existing member to stay as-is
          node[ k ] = x.dup
        end

        new_item_node
      end

      # ~ insertation (the two #hook-out's)

      def affix_to_prepared_node_P_node_Q_ node_P, node_Q

        node = node_P[ @tail_k ]  # node_P's tail struct is a shallow dup of
          # that of the prototype. (it has surface expression of e.g a space)

        node[ @item_k ] = nil  # no matter what, we do not want the content
          # member of the prototype

        node_Q.members.each do | k |  # now let every *trueish* member
          # of the new node clobber on top of that prepared node.

          x = node_Q[ k ]
          x or next
          node[ k ] = x
        end

        # the concert of the above gives us spacing from the prototype but
        # also trumping spacing from the existing node, as well as any of
        # its subsequent nodes.

        nil
      end

      def set_nodes_next_node_ node_P, node_Q

        node_P[ @tail_k ] = node_Q

        nil
      end

      # ~ mixed item production (the one #hook-out)

      def produce_new_mixed_item_via_string_argument_
        @front_node.class.parse( @tail_k, @new_s )[ @item_k ]
      end

      # ~ removal (three #hook-outs's)

      def remove_node_A_ node_A, node_B
        x = node_A.dup
        x[ @stem_k ] = nil
        node_B.members.each do | k |
          node_A[ k ] = node_B[ k ]
        end
        x[ @item_k ]
      end

      def remove_final_node_B_ node_A, node_B
        node_A[ @stem_k ] = nil
        node_B[ @item_k ]
      end

      def remove_nonfinal_node_B_ node_A, node_B, node_C
        node_A[ @stem_k ] = node_C
        node_B[ @stem_k ] = nil
        node_B[ @item_k ]
      end

      # ~ support

      def build_string_comparator_proc___
        s = @reference_s
        -> x do
          _ = x[ @item_k ]
          _.respond_to? :ascii_only? or self._SANITY  # while #open [#092]
          s == _
        end
      end
    end

    class Compound_Recursion_Operation_Session__ < Operation_Session__

      def initialize _, __, ___, list=nil
        super _, __, ___
        @list_k = list
      end

      attr_reader :list_k

      # ~ appendation (the two #hook-out's)

      def via_new_item_node_append_into_starter_stub_

        front_node = @front_node

        final_proto_node = _prototype_list.to_node_stream_.last

        final_proto_node.members.each do | k |
          front_node[ k ] = final_proto_node[ k ]
        end

        front_node[ @item_k ] = @new_item_x
        front_node
      end

      def via_new_item_node_append_to_only_node_using_prototype_list_ node, pl

        # create the new node before you mutate the existing node because
        # the prototype may actually be the parent node of the final node

        proto_Y, proto_Z = any_last_two_via_stream pl.to_node_stream_

        node_ = __produce_new_final_node_from_prototype_list proto_Z

        tail = __produce_tail_of_final_node node, proto_Y

        tail[ @list_k ] = node_

        # the previous final node still has "final node" "styling". it must
        # adopt the styling of the prototype's penultimate (which might also
        # be first) node.

        proto_Y.members.each do | sym |
          @item_k == sym and next
          @tail_k == sym and next
          x = proto_Y[ sym ]
          if x
            x = x.dup
          end
          node[ sym ] = x
        end

        node_
      end

      def __produce_new_final_node_from_prototype_list proto

        node = proto.dup
        node[ @item_k ] = nil  # safety

        tail = node[ @tail_k ]
        if tail
          tail = tail.dup
          tail[ @list_k ] = nil
          node[ @tail_k ] = tail
        end
        node[ @item_k ] = @new_item_x
        node
      end

      def __produce_tail_of_final_node node, proto

        tail = node[ @tail_k ]
        if ! tail
          tail = proto[ @tail_k ].dup
          tail[ @list_k ] = nil  # safety
          node[ @tail_k ] = tail
        end

        tail
      end

      # ~ insertation (the two #hook-out's)

      def affix_to_prepared_node_P_node_Q_ node_P, node_Q
        set_nodes_next_node_ node_P, node_Q
        nil
      end

      def set_nodes_next_node_ node_P, node_Q
        node_P[ @tail_k ][ @list_k ] = node_Q
        nil
      end

      # ~ mixed item production (the one #hook-out)

      def produce_new_mixed_item_via_string_argument_
        @front_node.class.parse( @list_k, @new_s )[ @item_k ]
      end

      # ~ removal (three #hook-out's)

      def remove_node_A_ node_A, node_B  # for now, differs only by k
        x = node_A.dup
        x[ @tail_k ] = nil
        node_B.members.each do | k |
          node_A[ k ] = node_B[ k ]
        end
        x
      end

      def remove_final_node_B_ node_A, _node_B

        # somewhat arbitrarily, we will preserve the tail structure

        tail = node_A[ @tail_k ]
        list = tail[ @list_k ]
        tail[ @list_k ] = nil
        list[ @item_k ]
      end
    end

    module Common_Static_Methods___

      attr_accessor :_prototype  # so that we can add to lists with zero or one items

      def list?  # #todo
        true
      end

      def _named_prototypes  # collude in a hack implemented elsewhere meh
      end

      def _nodes  # #open [#085]
        ::Enumerator.new do | y |
          st = to_node_stream_
          begin
            x = st.gets
            x or break
            y << x
            redo
          end while nil
        end
      end
    end

    class Prototype_Required < ::RuntimeError

      def initialize d, verb_phrase_symbol
        @items_count = d
        super "prototype required to #{
          }#{ verb_phrase_symbol.id2name.gsub( UNDERSCORE_, SPACE_ ) } #{
           }a list with#{ " only" if d.nonzero? } #{
            }item#{ 's' if 1 != d }"
      end

      attr_reader :items_count
    end

    UNDERSCORE_ = '_'.freeze
  end
  end
end
