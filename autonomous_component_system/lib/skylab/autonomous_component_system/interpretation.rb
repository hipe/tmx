module Skylab::Autonomous_Component_System

  # ->

    module Interpretation

      Accept_component_change = -> new_component, floating_qkn, acs do  # [mt] ONLY

        # guarantee storage of new component. result in proc that produces
        # event describing the change.

        asc = floating_qkn.association ; floating_qkn = nil

        # (disregard any "floating" value. we need to know if it was *stored*.)

        # make a note of any exisiting value before we replace it

        orig_qkn = ACS_::Reflection_::Read[ asc, acs ]

        # (we assume A) that we are [#003]:assumption-A not long-running, and that
        # B) in the typical request, at most one component will change (per
        # ACS, and in general). if one or more of A, B is not true, probably
        # the client should make some kind of component change writer..)

        ACS_::Interpretation_::Write_value[ new_component, asc, acs ]  # guaranteed

        # (see #resulting-in-proc)

        _LL = Home_.lib_.basic::List::Linked[ nil, asc.name ]

        looks_primitive = asc.model_classifications.looks_primitivesque

        as_new_component = if looks_primitive

          _new_qkn = Callback_::Qualified_Knownness.via_value_and_association(
            new_component, asc )

          ACS_::Primitivesque::As_Component.new _new_qkn
        else
          new_component
        end

        if orig_qkn.is_effectively_known  # #inout-A, [#]inout-B

          _as_previous_component = if looks_primitive
            ACS_::Primitivesque::As_Component.new orig_qkn
          else
            orig_qkn.value_x
          end

          -> do
            ACS_.event( :Component_Changed ).new_with(
              :current_component, as_new_component,
              :previous_component, _as_previous_component,
              :context_as_linked_list_of_names, _LL,
              :suggested_event_channel, [ :info, :component_changed ],
            )
          end
        else
          -> do
            ACS_.event( :Component_Added ).new_with(
              :component, as_new_component,
              :context_as_linked_list_of_names, _LL,
              :suggested_event_channel, [ :info, :component_added ],
              :verb_lemma_symbol, :set,
              :context_expresses_slot, true,  # "set C to X" !"added X to C"
            )
          end
        end
      end

      Build_empty_hot = -> asc, acs do

        # assume model is "entitesque" (not primitive-esque).
        # create a new empty component that is bound to the ACS.
        # new component is *NOT* stored as a member value in that ACS.

        block_given? and self._NO  # in practice no one ever wants to
        # pass their own handler builder YET. but we can change this
        # easily. for now it's always just:

        _oes_p_p = CHB[ asc, acs ]

        o = ACS_::Interpretation_::Build_value.new nil, asc, acs, & _oes_p_p

        o.mixed_argument = if o.looks_like_compound_component__
          IDENTITY_
        else
          Callback_::Polymorphic_Stream.the_empty_polymorphic_stream
        end

        o.execute.value_x  # ..
      end

      find_handler_method = nil
      CHB = -> asc, acs do  # :[#-CHB]

        # "component handler builder" (experimental): pass component listener
        # both the component value and association whenever it emits.

        -> cmp do  # :[#006]:codepoint-1

          -> * i_a, & x_p do

            qkn = Callback_::Qualified_Knownness[ cmp, asc ]

            st = Callback_::Polymorphic_Stream.via_array i_a

            m = find_handler_method[ st, acs ]

            if m
              _maybe_none = st.flush_remaining_to_array

              acs.send m, qkn, * _maybe_none, & x_p
            else

              acs.receive_component_event qkn, i_a, & x_p
            end
          end
        end
      end

      find_handler_method = -> st, acs do

        # shift elements from the channel on to the method
        # name as long as there is a matching method

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
        m
      end

      class Value_Popper  # :+[#006]:VP

        class << self
          alias_method :[], :new
          private :new
        end  # >>

        def initialize x
          @current_token = x
          @unparsed_exists = true
        end

        def gets_one
          @unparsed_exists = true
          remove_instance_variable :@current_token
        end

        def no_unparsed_exists
          ! @unparsed_exists
        end

        attr_reader(
          :current_token,
          :unparsed_exists
        )
      end

      Looks_primitive = -> x do  # `nil` is NOT primitive by this definition!
        case x
        when ::TrueClass, ::Fixnum, ::Float, ::Symbol, ::String  # [#003]inout-C
          true
        else
          false
        end
      end

      IDENTITY_ = -> x { x }
    end
  # -
end
