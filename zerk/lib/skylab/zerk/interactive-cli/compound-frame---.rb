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
        @_loadable_reference = lt
        h = lt.custom_tree_hash__
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

    def begin_UI_panel_expression

      # you've got to index "every time" you come to this frame, in case
      # (for example) an adapter has changed in your plugin architecture.

      __reindex_everything
      NIL_
    end

    def end_UI_panel_expression
      # remove_instance_variable :@_loadable_references_for_UI  # used again ..
      NIL_
    end

    def to_every_node_reference_stream_  # near c.p w/ #spot1.7

      Common_::Stream.via_nonsparse_array @_loadable_references_for_UI do |x|
        x.node_reference
      end
    end

    def __reindex_everything

      # (when you get to [#021] availability, maybe here is where you would
      # do some serious indexing to make some nodes (of various sorts)
      # disabled (that is, not visible or accessible at all)..)

      loadable_references = []

      # (during #description, use the above somehow ..)

      butz = Here_::Buttonesque_Expression_Adapter_::Frame.begin

      h = @__any_custom_tree_hash || MONADIC_EMPTINESS_

      st = reader_writer.to_node_reference_streamer.execute

      begin
        nt = st.gets
        nt or break

        if nt.is_a_singular  # justification at #commit-A at end of file
          redo
        end

        _cust_x = h[ nt.name_symbol ]

        lt = Here_::LoadableReference_[ _cust_x, nt, self ]
        lt or redo  # #mode-tweaking

        butz.add lt
        loadable_references.push lt

        # (the remainder of this loop is for #defaults)

        :association == nt.node_reference_category or redo
        asc = nt.association
        p = asc.default_proc
        p or redo
        reader_writer.write_if_not_set Common_::QualifiedKnownKnown[ p[], asc ]
        redo
      end while nil

      @button_frame = butz.finish
      @_loadable_references_for_UI = loadable_references
      NIL_
    end

    def to_asset_reference_stream_for_UI
      Common_::Stream.via_nonsparse_array @_loadable_references_for_UI
    end

    def to_stream_for_resolving_buttonesque_selection
      Common_::Stream.via_nonsparse_array @button_frame
    end

    # -- user input

    def process_mutable_string_input s

      s.strip!  # here we strip not chomp because node names are more normal
      if s.length.zero?
        @line_yielder << "(nothing entered.)"
      else
        lt = Here_::Buttonesque_Interpretation_Adapter_[ s, self ]
        if lt
          lt.on_loadable_reference_pressed
        end
      end
      NIL_
    end

    # -- reflection for ancilliaries

    def build_formal_operation_via_node_reference_ nt

      ss = Build_frame_stack_as_array_[ self ]
      ss.push nt.name
      _fo = nt.proc_to_build_formal_operation.call ss
      _fo  # #todo
    end

    def for_invocation_read_atomesque_value_ asc
      @_rw.read_value asc
    end

    # -- emissions (events)

    def interruption_handler  # c.p w/ [#045]
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
      @_rw ||= ACS_::Magnetics::FeatureBranch_via_ACS.for_componentesque @ACS
    end

    def name  # will fail for root compound frame
      @_loadable_reference.name
    end

    attr_reader(
      :ACS,
      :below_frame,
      :button_frame,
      :event_loop,
      :UI_event_handler,  # for buttonesque
    )

    def four_category_symbol
      :compound
    end
  end

  end
end
# #commit-A is where we add the spec that explains the justification of this
