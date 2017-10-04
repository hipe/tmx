module Skylab::BeautySalon

  class CrazyTownMagnetics_::StructuredNode_via_Writes < Common_::MagneticBySimpleModel

    # similar to the important pattern demonstrated by `::Ast::Node`, our
    # structured nodes are "virtually immutable". (different from being
    # *truly* immutable, they allow themselves to evaluate some data members
    # lazily. but to any outside observer (client) they are for all intents
    # and purposes immutable.)
    #
    # this means that to achieve the effect of "editing" (for example a
    # document), we do not mutate existing structured notes. instead we
    # create a duplicate of an existing structured node with particular
    # edits to it..

    # -
      attr_writer(
        :edit,
        :structured_node,
      )

      def execute
        __init_hash_of_writes
        __init_new_children_array_and_um_dot_dot
        __assemble_new_structured_node
      end

      def __assemble_new_structured_node

        _new_cx = remove_instance_variable :@__new_children_array

        _new_properties = { location: @_original_node.location }

          # NOTE - this will very likely bite us - we carry over the location
          # map of the original after having edited it..


        _new_node = @_original_node.updated(
          nil,
          _new_cx,
          _new_properties,
        )

          # NOTE - originally we thought of trying to carry over cached
          # structured nodes that hadn't changed; but meh..


        @structured_node.class.via_node_ _new_node
      end

      def __init_new_children_array_and_um_dot_dot

        # (the below resides squarely atop the concern of [#007.E] "the main
        # mapping challenge", something that is not yet well documented #todo)

        # ulimately what we need is the new array of children AST nodes.
        #
        # we can try to model what we are doing as a comprehensive list of
        # "operations" that are performed on the received array of children
        # to produce the new, edited array.

        # consider such a received array of children:
        #
        #     cx0   cx1   cx2   cx3   cx4   cx5
        #
        #              |<- plural arity ->|
        #
        # i.e, the children whose association is of a non-plural arity are:
        # cx0, cx1, cx5. the children of an association with a plural arity
        # are: cx2, cx3, cx4.
        #
        # the changes we are modeling fall squarely into these two
        # categories: one, changes for associations of a non-plural arity;
        # and two, changes for associations with a plural arity.
        #
        # for those children of a non-plural arity, (under the present model)
        # we can A) express this in terms of operation-per-child, and B) we
        # can say that there are only ever two operations we will ever need
        # to support for each of these children: either keep it the same, or
        # change it to some given new value. (note that under the present
        # model these operations cannot change the overall number of
        # children; i.e although we could, we do not model this as children
        # being possibly removed then added; rather we see this as each
        # child being either changed or not changed.)
        #
        # as for the run of children under the plural arity, there is a
        # number of ways we could express an edit to this run (imagine a
        # diff (patch) structure (YIKES!)). to keep things relatively more
        # simple we will say that there are two ways to express the any
        # change for this run: either A) nothing, meaning change nothing, or
        # B) a totally new array holding whatever new values are supposed to
        # be there (some of these values may be unchanged.) the difference
        # in length between the new array and the original *run* in the
        # received array will constitute the overall change in length of
        # the children array (if any).
        #
        # putting these two categories together (again under the current
        # model), we can assemble the new array of children by saying:
        # A) do the any head run for the first category
        # B) do the any run for the plural arity (2nd category)
        # C) to the any tail run for the first category

        new_children_array = []  # length to be determined

        h = remove_instance_variable( :@__hash_of_writes ).dup  # was immutable

        ascs = @structured_node.class.children_association_index.associations
        num_ascs = ascs.length

        step = nil

        @_original_node = @structured_node._node_
        existing_children_array = @_original_node.children
        current_real_offset = -1

        at_head_or_tail = -> any_pair, asc do
          current_real_offset += 1
          if any_pair
            x, = any_pair  # (second value is asc)
            if asc.is_terminal
              new_children_array.push x
            else
              ::Kernel._COVER_ME__be_sure_this_is_a_structured_child__
            end
          else
            new_children_array.push existing_children_array.fetch current_real_offset
          end
        end

        tail_step = -> any_pair, asc do
          asc.has_plural_arity && sanity
          at_head_or_tail[ any_pair, asc ]
        end

        current_association_offset = -1

        at_plural = -> any_pair, asc do
          if any_pair
            ::Kernel._COVER_ME__xx__
          else
            # carry-over every child as-is, while keeping our counting intact
            _this_many = existing_children_array.length - num_ascs + 1
            _this_many.times do
              current_real_offset += 1
              new_children_array.push existing_children_array.fetch current_real_offset
            end
          end
        end

        step = -> any_pair, asc do
          if asc.has_plural_arity
            step = tail_step
            at_plural[ any_pair, asc ]
          else
            at_head_or_tail[ any_pair, asc ]
          end
        end

        ascs.each do |asc|
          current_association_offset += 1
          step[ h.delete( asc.association_symbol ), asc ]
        end

        h.length.zero? || sanity

        @__new_children_array = new_children_array.freeze
        NIL
      end

      def __init_hash_of_writes
        @__hash_of_writes = HashOfWrites__via_TheseTwo___.new(
          remove_instance_variable( :@edit ),
          @structured_node,
        ).execute
        NIL
      end

    # -

    class HashOfWrites__via_TheseTwo___

      def initialize p, n
        @edit = p
        @structured_node = n
      end

      def execute

        if ! __class_for_writing_defined
          __define_class_for_writing
        end

        __initialize_things_to_record_writes
        __gather_the_writes
        __release_the_writes
      end

      def __release_the_writes
        remove_instance_variable( :@__callbacker ).close
      end

      # -- gather the writes

      def __gather_the_writes
        _wr = remove_instance_variable :@__writes_receiver
        remove_instance_variable( :@edit )[ _wr ]
        NIL
      end

      def __initialize_things_to_record_writes
        _cls = _module_to_write_class_into.const_get CONST__, false
        @__writes_receiver = _cls.new { |cb| @__callbacker = cb }
        NIL
      end

      # -- define the writing class

      def __define_class_for_writing
        cls = ::Class.new WriteReceiver___
        _module_to_write_class_into.const_set CONST__, cls
        these = __associations
        cls.class_exec do
          these.each do |asc|
            if asc.is_terminal  # (NOTE all terminals are writable for now)
              define_method :"#{ asc.stem_symbol }=" do |x|
                __receive_terminal_write x, asc
              end
            elsif asc.has_plural_arity
              define_method asc.association_symbol do
                __produce_wired_list_editing_proxy asc
              end
            else
              define_method :"#{ asc.association_symbol }=" do |x|
                __receive_structured_child x, asc
              end
            end
          end
        end
        NIL
      end

      def __class_for_writing_defined
        _module_to_write_class_into.const_defined? CONST__, false  # #[#here.D] inheritence
      end

      def _module_to_write_class_into
        @structured_node.class
      end

      def __associations
        @structured_node.class.children_association_index.associations
      end
    end

    # ==

    class WriteReceiver___

      # make sure that for any given association, there is at most one
      # write to it. result is an array of pairs, where each pair is
      # (second) the association and (first) some mixed new value
      # appropriate to the kind of association.

      def initialize

        _cb = WritesCallbacker___.define do |o|
          o.receive_close = -> do
            __close
          end
        end

        yield _cb

        @_data_for_write_via_association_symbol = {}
      end

      def __produce_wired_list_editing_proxy
        ::Kernel._COVER_ME__crazy_list_editing_proxy__
      end

      def __receive_structured_child x, asc
        ::Kernel._COVER_ME__write_a_structured_child__
      end

      def __receive_terminal_write x, asc

        asc.hacky_type_check__ x

        h = @_data_for_write_via_association_symbol
        k = asc.association_symbol
        would_clobber = true
        h.fetch k do
          would_clobber = false
          h[ k ] = [ x, asc ] ; true
        end
        if would_clobber
          self._COVER_ME__cannot_clobber_existing_writes__
        end
      end

      def __close
        remove_instance_variable( :@_data_for_write_via_association_symbol ).freeze
      end
    end

    class WritesCallbacker___ < Common_::SimpleModel

      def receive_close= p
        @__close = p
      end

      def close
        @__close[]
      end
    end

    # ==

    CONST__ = :ProxyForWrites

    # ==
    # ==
  end
end
# #abstracted from sibling file with source still in existence (progressive refactor)
