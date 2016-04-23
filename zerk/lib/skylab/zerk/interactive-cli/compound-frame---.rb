module Skylab::Zerk

  class InteractiveCLI

  class Compound_Frame___  # (built in 1 place by event loop)

    def initialize acs, ccv, el
      @ACS = acs
      @compound_custom_view = ccv
      @_indexed = nil
      @line_yielder = el.line_yielder
      @UI_event_handler = el.UI_event_handler
      @event_loop = el
    end

    # --

    def accept_new_component_value__ qk
      reader_writer_.write_value qk
      NIL_
    end

    def qualified_knownness_for__ nt
      _ = reader_writer_.qualified_knownness_of_association nt.association
      _  # #todo
    end

    def knownness_for__ nt
      _ = reader_writer_.read_value nt.association
      _  # #todo
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

      o = reader_writer_.to_node_ticket_streamer
      o.on_association = nil  # (hi.) x2
      o.on_operation = nil
      st = o.execute

      load_tickets = []

      # (during #description, use the above somehow ..)

      butz = Here_::Buttonesque_Expression_Adapter_::Frame.begin

      h = if @compound_custom_view
        @compound_custom_view.custom_tree_for
      else
        MONADIC_EMPTINESS_
      end

      begin
        nt = st.gets
        nt or break

        _cust_x = h[ nt.name_symbol ]
        lt = Here_::Load_Ticket_[ _cust_x, nt, self ]

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
        x = Here_::Buttonesque_Interpretation_Adapter_[ s, self ]
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

    # -- support and exposure

    def reader_writer_
      @___rw ||= ACS_::ReaderWriter.for_componentesque @ACS
    end

    # -- as structure

    attr_reader(
      :ACS,
    )

    # -- instrinsic shape reflection

    def shape_symbol
      :branchesque
    end
  end

  end
end
