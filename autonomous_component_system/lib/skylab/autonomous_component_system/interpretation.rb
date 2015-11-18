module Skylab::Autonomous_Component_System

  # ->

    module Interpretation

      Accept_component_change = -> new_component, asc, acs do  # [mt] ONLY

        # guarantee storage of new component. result in proc that produces
        # event describing the change.

        # make a note of any exisiting value before we replace it

        orig_qkn = ACS_::Reflection_::Read[ asc, acs ]

        # (we assume A) that we are [#003]:assumption-A not long-running, and that
        # B) in the typical request, at most one component will change (per
        # ACS, and in general). if one or more of A, B is not true, probably
        # the client should make some kind of component change writer..)

        ACS_::Interpretation_::Write_value[ new_component, asc, acs ]  # guaranteed

        # (see #resulting-in-proc)

        _LL = Home_.lib_.basic::List::Linked[ nil, asc.name ]

        if orig_qkn.is_effectively_known  # #inout-A, [#]inout-B

          -> do
            ACS_.event( :Component_Changed ).new_with(
              :current_component, new_component,
              :previous_component, orig_qkn.value_x,
              :context_as_linked_list_of_names, _LL,
              :suggested_event_channel, [ :info, :component_changed ],
            )
          end
        else
          -> do
            ACS_.event( :Component_Added ).new_with(
              :component, new_component,
              :context_as_linked_list_of_names, _LL,
              :suggested_event_channel, [ :info, :component_added ],
              :verb_lemma_symbol, :set,
              :context_expresses_slot, true,  # "set C to X" !"added X to C"
            )
          end
        end
      end

      Build_empty_hot = -> asc, acs, & oes_p do

        # assume model is "entitesque" (not primitive-esque).
        # create a new empty component that is bound to the ACS.
        # new component is *NOT* stored as a member value in that ACS.

        o = ACS_::Interpretation_::Build_value.new nil, asc, acs, & oes_p

        o.mixed_argument = if o.looks_like_compound_component__
          IDENTITY_
        else
          Callback_::Polymorphic_Stream.the_empty_polymorphic_stream
        end

        o.execute.value_x  # ..
      end

      Component_handler = -> asc, acs do

        # see [#006]:#how-components-are-bound-to-listeners (4 lines)

        -> * i_a, & x_p do

          st = Callback_::Polymorphic_Stream.via_array i_a

          base = :"receive_component__"
          begin

            try_m = :"#{ base }#{ st.current_token }__"

            if acs.respond_to? try_m
              m = try_m
              st.advance_one
              if st.unparsed_exists
                base = try_m
                redo
              end
            end
            break
          end while nil

          if m
            _maybe_none = st.flush_remaining_to_array
            acs.send m, asc, * _maybe_none, & x_p
          else
            acs.receive_component_event asc, i_a, & x_p
          end
        end
      end

      class Value_Popper  # :+[#006]:VP

        class << self
          alias_method :[], :new
          private :new
        end  # >>

        def initialize x

          @unparsed_exists = true
          @_p = -> do
            @unparsed_exists = false
            remove_instance_variable :@_p
            x
          end
        end

        def gets_one
          @_p[]
        end

        def no_unparsed_exists
          ! @unparsed_exists
        end

        attr_reader :unparsed_exists
      end

      IDENTITY_ = -> x { x }
    end
  # -
end
