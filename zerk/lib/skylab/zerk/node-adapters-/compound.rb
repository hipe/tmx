module Skylab::Zerk

  class Node_Adapters_::Compound  # (built in 1 place by event loop)

    def initialize acs, ccv, rsx
      # (currently `rsx` is actually the event loop)
      @ACS = acs
      @compound_custom_view = ccv
      @_indexed = nil
      @line_yielder = rsx.line_yielder
      @UI_event_handler = rsx.UI_event_handler
      @event_loop = rsx.event_loop
    end

    # -- ..

    def begin_UI_frame
      __index_for_UI_frame
      NIL_
    end

    def end_UI_frame
      # remove_instance_variable :@_UI_frame_nodes  # used again ..
      NIL_
    end

    def __index_for_UI_frame

      load_tickets = []
      st = UI_node_stream_for___[ @ACS ]

      # (during #description, use the above somehow ..)

      butz = Home_::Expression_Adapters_::Buttonesque::Frame.begin

      h = if @compound_custom_view
        @compound_custom_view.custom_tree_for
      else
        MONADIC_EMPTINESS_
      end

      begin
        qkn = st.gets
        qkn or break

        _cust_x = h[ qkn.name.as_variegated_symbol ]
        lt = Home_::Load_Ticket_[ _cust_x, qkn, ]

        butz.add lt

        load_tickets.push lt

        redo
      end while nil

      @_button_frame = butz.finish
      @_UI_frame_nodes = load_tickets
      NIL_
    end

    def to_UI_frame_item_stream
      Callback_::Stream.via_nonsparse_array @_UI_frame_nodes
    end

    def to_stream_for_resolving_buttonesque_selection
      Callback_::Stream.via_nonsparse_array @_button_frame
    end

    # -- expression

    def button_frame
      @_button_frame
    end

    # -- user input

    def process_mutable_string_input s

      s.strip!  # here we strip not chomp because node names are more normal
      if s.length.zero?
        @line_yielder << "(nothing entered.)"
      else
        x = Home_::Interpretation_Adapters_::Buttonesque[ s, self ]
        if x
          @event_loop.push_stack_frame_for x
        end
      end
      NIL_
    end

    attr_reader(
      :UI_event_handler,  # for buttonesque
    )

    # -- events

    def handler_for sym, *_
      if :interrupt == sym
        -> do
          @event_loop.pop_me_off_of_the_stack self
          NIL_
        end
      end
    end

    def receive_uncategorized_emission i_a, & ev_p

      @event_loop.receive_uncategorized_emission i_a, & ev_p
      UNRELIABLE_
    end

    # -- as structure

    attr_reader(
      :ACS,
    )

    # -- instrinsic shape reflection

    def shape_symbol
      :branchesque
    end

    MONADIC_EMPTINESS_ = -> _ { NIL }
    UI_node_stream_for___ = Interface_stream_for_.curry[ :UI ]
  end
end
