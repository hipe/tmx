module Skylab::TMX

  module Models::Reorder

    # one does not simply use the the `order` primary against any formal
    # attribute out of the box. whether an attribute can be sorted against
    # and how to sort against it is a responsibility of the attribute itself,
    # that it either does or doesn't opt-in to by providing (or not) an
    # "order plan" for each given "order request".

    class Plan_via_parse_client < Common_::Actor::Monadic

      # - keep knowledge of the sub-syntax of this modifer out of the main
      #   operation parser.
      #
      # - the sole communicator with attribute implementations of how
      #   to broker a reorder plan.

      def initialize pc, & p
        @parse_client = pc
        @_emit = p
      end

      def execute
        if __parse_formal_attribute
          __maybe_parse_reverse
          __broker_with_attribute
        else
          UNABLE_  # did whine on unable to parse formal attribute
        end
      end

      def __broker_with_attribute  # emit if failure

        _req = Request___.new @is_forwards, @attribute
        @attribute.plan_for_reorder_via_reorder_request__ _req, & @_emit
      end

      def __maybe_parse_reverse
        scn = @parse_client.argument_scanner
        if scn.no_unparsed_exists
          @is_forwards = true
        else
          _sym = scn.head_as_primary_symbol
          if :reverse == _sym
            scn.advance_one
            @is_forwards = false
          else
            @is_forwards = true
          end
        end
        NIL
      end

      def __parse_formal_attribute
        _store :@attribute, @parse_client.parse_formal_attribute_
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    # ==

    Request___ = ::Struct.new :is_forwards, :attribute

      # represent the `order` primary and its any modifiers.

    # ==

    class CommonPlan

      # is placed in the map modification index.

      def initialize req, key
        @attribute = req.attribute
        @__is_forwards = req.is_forwards
        @__key = key
      end

      def group_list_via_item_list item_a

        o = Home_::Magnetics_::GroupList_via_ItemList_and_Key_and_Options.
          begin( item_a, @__key )

        o.is_forwards = @__is_forwards

        o.execute
      end

      attr_reader(
        :attribute,
      )

      def produces_final_group_list
        false
      end
    end

    # ==
  end
end
# #history: rewrite and rename of "reorderation"
