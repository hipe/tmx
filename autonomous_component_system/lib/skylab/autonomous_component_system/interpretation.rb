module Skylab::Autonomous_Component_System

  # ->

    module Interpretation

      Accept_component_change = -> new_x, asc, acs, & _LL_p do

        # guarantee storage of new component. result in proc that produces
        # event describing the change.

        # make a note of any exisiting value before we replace it

        orig_qkn = ACS_::Reflection_::Read[ asc, acs ]

        # (we assume A) that we are [#003]:not-long-running, and that
        # B) in the typical request, at most one component will change (per
        # ACS, and in general). if one or more of A, B is not true, probably
        # the client should make some kind of component change writer..)

        ACS_::Interpretation_::Write_value[ new_x, asc, acs ]  # guaranteed

        # (see #resulting-in-proc)

        as_component_via_component = -> x do

          # for a value to be compatible with [#br-035] expressive events
          # it must respond to one particular method. it is certainly not
          # within the domain of concern of the primitive component value
          # to respond to this method so we put it in a wrapper that does

          as_component_via_component = if asc.model_classifications.looks_primitivesque
            Primitivesque_As_Component___.method :new
          else
            IDENTITY_
          end

          as_component_via_component[ x ]
        end

        build_linked_list_of_context = -> do
          if _LL_p
            _LL_p[]
          else
            Home_.lib_.basic::List::Linked[ nil, asc.name ]
          end
        end

        if orig_qkn.is_effectively_known  # #nil-note, [#]false-note

          -> do

            _as_new_comp = as_component_via_component[ new_x ]
            _as_prev_comp = as_component_via_component[ orig_qkn.value_x ]
            _LL = build_linked_list_of_context[]

            ACS_.event( :Component_Changed ).new_with(
              :current_component, _as_new_comp,
              :previous_component, _as_prev_comp,
              :context_as_linked_list_of_names, _LL,
              :suggested_event_channel, [ :info, :component_changed ],
            )
          end
        else

          -> do

            _as_new_comp = as_component_via_component[ new_x ]
            _LL = build_linked_list_of_context[]

            ACS_.event( :Component_Added ).new_with(
              :component, _as_new_comp,
              :context_as_linked_list_of_names, _LL,
              :suggested_event_channel, [ :info, :component_added ],
              :verb_lemma_symbol, :set,
              :context_expresses_slot, true,  # "set C to X" !"added X to C"
            )
          end
        end
      end

      class Primitivesque_As_Component___

        def initialize x
          @_x = x
        end

        def description_under expag
          x = @_x
          expag.calculate do
            val x
          end
        end
      end

      Build_empty_hot = -> asc, acs do  # result is qk

        # assume model is "entitesque" (not primitive-esque).
        # create a new empty component that is bound to the ACS.
        # new component is *NOT* stored as a member value in that ACS.

        block_given? and self._NO  # in practice no one ever wants to
        # pass their own handler builder YET. but we can change this
        # easily. for now it's always just:

        _oes_p_p = CHB[ asc, acs ]

        o = ACS_::Interpretation_::Build_value.begin nil, asc, acs, & _oes_p_p

        o.mixed_argument = if o.looks_like_compound_component__
          IDENTITY_
        else
          Callback_::Polymorphic_Stream.the_empty_polymorphic_stream
        end

        o.execute
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
          @_done = false
          @_kn = Callback_::Known_Known[ x ]
        end

        def gets_one
          x = current_token
          advance_one
          x
        end

        def current_token
          @_kn.value_x
        end

        def advance_one
          remove_instance_variable :@_kn
          @_done = true ; nil
        end

        def unparsed_exists
          ! @_done
        end

        def no_unparsed_exists
          @_done
        end
      end

      Looks_primitive = -> x do  # `nil` is NOT primitive by this definition!
        case x
        when ::TrueClass, ::Fixnum, ::Float, ::Symbol, ::String  # [#003]#trueish-note
          true
        else
          false
        end
      end

      IDENTITY_ = -> x { x }
    end
  # -
end
