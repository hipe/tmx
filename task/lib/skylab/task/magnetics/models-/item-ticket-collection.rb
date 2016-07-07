class Skylab::Task

  module Magnetics

    class Models_::ItemTicketCollection

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize
        NOTHING_  # every ivar is instantiated lazily
      end

      attr_writer(
        :item_resolver,
      )

      def accept_item_ticket it
        send ACCEPT___.fetch( it.category_symbol ), it
        NIL_
      end

      ACCEPT___ = {
        function: :__accept_function,
        manner: :__accept_manner,
        unassociated: :__accept_unassociated,
      }

      def __accept_manner ma

        # manner_box[ slot_terminal_symbol ][ manner_terminal_symbol ] => manner

        @manner_box ||= Common_::Box.new

        _bx = @manner_box.touch ma.slot_term_symbol do
          Common_::Box.new
        end

        _bx.add ma.manner_term_symbol, ma

        NIL_
      end

      def __accept_function fu
        ( @__function_items ||= [] ).push fu
        NIL_
      end

      def __accept_unassociated ma
        @UNASSOCIATEDS_WERE_ADDED_BUT_IGNORED = true
        NIL_
      end

      def finish
        self
      end

      # -- use manners

      def write_manner_methods_onto cls
        Here_::Magnetics_::EnhancedClass_via_Class_and_ItemTicketCollection[ cls, self ]
      end

      def manner_slot_setter_class_cache___
        @___mssc_cache ||= {}
      end

      # -- use functions

      def to_function_item_ticket_stream__
        Common_::Stream.via_nonsparse_array @__function_items
      end

      def proc_for_read_function_item_ticket_via_const

        function_index_.proc_for_read_function_item_ticket_via_const__
      end

      def proc_for_read_function_item_via_function_item_ticket

        -> fit do
          @item_resolver[ fit ]  # (hi.)
        end
      end

      def function_index_
        @___fi ||= Here_::Magnetics_::FunctionIndex_via_ItemTicketCollection[ self ]
      end

      # -- support

      def __item_via_item_ticket it
        @item_resolver[ it ]
      end

      counter_h = ::Hash.new { |h, k| h[k] = 0 }  # constants are forever

      define_method :begin_dynamic_class__ do |stem, base_class|
        d = counter_h[ stem ]
        d += 1
        counter_h[ stem ] = d
        cls = ::Class.new base_class
        This_.const_set "#{ stem }#{ d }", cls
        cls
      end

      # --

      attr_reader(
        :manner_box,
      )

      This_ = self
    end
  end
end
