module Skylab::Zerk

  class InteractiveCLI

  class Compound_Frame___  # (built in 1 place by event loop)

    def initialize below_frame, acs, lt, el

      @ACS = acs
      @below_frame = below_frame
      @event_loop = el
      @line_yielder = el.line_yielder
      @UI_event_handler = el.UI_event_handler

      if lt
        @_load_ticket = lt
        h = lt.custom_tree_hash__
        # :#here also something about masking, at [#041]
      end

      @__any_custom_tree_hash = h
    end

    # --

    def accept_new_component_value__ qk
      reader_writer.write_value qk
      NIL_
    end

    def qualified_knownness_for__ nt
      _ = reader_writer.qualified_knownness_of_association nt.association
      _  # #todo
    end

    def knownness_for__ nt
      _ = reader_writer.read_value nt.association
      _  # #todo
    end

    # -- ..

    def begin_UI_frame
      __index_for_UI_frame
      NIL_
    end

    def end_UI_frame
      # remove_instance_variable :@_load_tickets_for_UI  # used again ..
      NIL_
    end

    def __index_for_UI_frame

      # (when you get to [#021] availability, maybe here is where you would
      # do some serious indexing to make some nodes (of various sorts)
      # disabled (that is, not visible or accessible at all)..)

      o = reader_writer.to_node_ticket_streamer
      o.on_association = nil  # (hi.) x2
      o.on_operation = nil
      st = o.execute

      load_tickets = []

      # (during #description, use the above somehow ..)

      butz = Here_::Buttonesque_Expression_Adapter_::Frame.begin

      h = @__any_custom_tree_hash || MONADIC_EMPTINESS_

      begin
        nt = st.gets
        nt or break

        _cust_x = h[ nt.name_symbol ]
        lt = Here_::Load_Ticket_[ _cust_x, nt, self ]

        butz.add lt
        load_tickets.push lt

        redo
      end while nil

      @button_frame = butz.finish
      @_load_tickets_for_UI = load_tickets
      NIL_
    end

    def to_load_ticket_stream_for_UI
      Callback_::Stream.via_nonsparse_array @_load_tickets_for_UI
    end

    def to_stream_for_resolving_buttonesque_selection
      Callback_::Stream.via_nonsparse_array @button_frame
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

    # -- reflection for ancilliaries

    def build_formal_operation_via_node_ticket_ nt

      ss = Build_frame_stack_as_array_[ self ]
      ss.push nt.name
      _fo = nt.proc_to_build_formal_operation.call ss
      _fo  # #todo
    end

    def to_every_node_ticket_stream_  # near c.p w/ #spot-7

      sr = reader_writer.to_node_ticket_streamer

      # .. see #here

      sr.call
    end

    def for_invocation_read_atomesque_value_ asc
      @_rw.read_value asc
    end

    # -- emissions (events)

    def interruption_handler  # c.p w/ #spot-6
      -> do
        @event_loop.pop_me_off_of_the_stack self
        NIL_
      end
    end

    def receive_uncategorized_emission i_a, & ev_p

      @event_loop.receive_uncategorized_emission i_a, & ev_p
      UNRELIABLE_
    end

    # --

    def CHANGE_ACS x  # 1x [my] (EXPERIMENTAL)

      @_rw.clear_cache  # note that inside this still has the old ACS
      @ACS = x
      NIL_
    end

    def reader_writer
      @_rw ||= ACS_::ReaderWriter.for_componentesque @ACS
    end

    def name  # will fail for root compound frame
      @_load_ticket.name
    end

    attr_reader(
      :ACS,
      :below_frame,
      :button_frame,
      :UI_event_handler,  # for buttonesque
    )

    def four_category_symbol
      :compound
    end
  end

  end
end
