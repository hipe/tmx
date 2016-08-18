class Skylab::Task

  module Magnetics

    class Models_::ItemTicketCollection

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize
        @_function_items = []
        @manner_box = nil
      end

      attr_writer(
        :item_resolver,
      )

      def add_constants_not_in_filesystem mod

        h = {}
        @_function_items.each do |fi|
          h[ fi.const ] = true
        end
        bx = @manner_box
        if bx
          bx.each_value do |bx_|
            bx_.each_value do |mit|
              h[ mit.const ] = true
            end
          end
        end
        mod.constants.each do |sym|
          h[ sym ] && next
          _ts = Here_::Magnetics_::TokenStream_via_Const[ sym ]
          _it = Magnetics_::ItemTicket_via_TokenStream[ _ts ]
          accept_item_ticket _it
        end
        NIL_
      end

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
        @_function_items.push fu
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
        Common_::Stream.via_nonsparse_array @_function_items
      end

      def const_for_A_atom_via_B_atom sym_A, sym_B
        Here_::Models_::Function_ItemTicket::Const[ [sym_A], [sym_B] ]
      end

      def read_function_item_ticket_via_const const

        function_index_.read_function_item_ticket_via_const__ const
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
