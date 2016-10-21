module Skylab::TMX

  class Models_::Reorderation

    # an internal parse structure of an `order` modifer for the `map` commad.
    # responsibilities/objective:
    #
    #   - keeps knowledge of the sub-syntax of this modifer out of
    #     the main operation parser.
    #
    #   - is the sole communicator with attribute implementations of
    #     how to broker a reordering plan.
    #
    # is placed in the map modification index.

    class << self

      def via_parse_client__ pc, & emit
        new( pc, & emit ).finish
      end
      private :new
    end  # >>

    def initialize pc, & p
      @parse_client = pc
      @_emit = p
    end

    # -- write-time

    def finish

      if __parse_formal_attribute
        __maybe_parse_reverse
        if __broker_with_attribute
          __close
        else
          UNABLE_
        end
      else
        UNABLE_  # did whine on unable to parse formal attribute
      end
    end

    def __close
      remove_instance_variable :@parse_client
      remove_instance_variable :@_emit
      freeze
    end

    def __broker_with_attribute  # emit if failure

      _ = @attribute.reorderation_implementation_via_reorderation self, & @_emit
      _store :@implementation, _
    end

    def __parse_formal_attribute
      _store :@attribute, @parse_client.parse_formal_attribute_
    end

    def __maybe_parse_reverse
      scn = @parse_client.argument_scanner
      if scn.no_unparsed_exists
        @is_forwards = true
      else
        _sym = scn.head_as_normal_symbol
        if :reverse == _sym
          scn.advance_one
          @is_forwards = false
        else
          @is_forwards = true
        end
      end
      NIL
    end

    define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

    # -- read-time

    def group_list_via_item_list__ item_a
      @implementation.group_list_via_item_list item_a
    end

    attr_reader(
      :attribute,
      :is_forwards,
    )

    # ==

    class By < ::Proc

      alias_method :group_list_via_item_list, :call
      undef_method :call
    end

    # ==
  end
end
