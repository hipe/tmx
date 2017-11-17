module Skylab::Arc

  Magnetics::WriteComponent_via_QualifiedComponent_and_FeatureBranch =
    # this name is wishful thinking..

      # ==

      -> new_qkn, reader_writer, & _LL_p do

        # storage of new component is "guaranteed".
        # result is proc that produces an event describing the change.

        asc = new_qkn.association
        new_x = new_qkn.value

        # make a note of any exisiting value before we replace it
        orig_kn = reader_writer.read_value asc

        # replace it
        reader_writer.write_value new_qkn

        # (see #resulting-in-proc)

        as_component_via_component = -> x do

          # for a value to be compatible with [#007] expressive events
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

        if orig_kn.is_effectively_known  # [#003.H] about nil, [#003.I] about false

          -> do

            _as_new_comp = as_component_via_component[ new_x ]
            _as_prev_comp = as_component_via_component[ orig_kn.value ]
            _LL = build_linked_list_of_context[]

            Home_::Events::ComponentChanged.with(
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

            Home_::Events::ComponentAdded.with(
              :component, _as_new_comp,
              :context_as_linked_list_of_names, _LL,
              :suggested_event_channel, [ :info, :component_added ],
              :verb_lemma_symbol, :set,
              :context_expresses_slot, true,  # "set C to X" !"added X to C"
            )
          end
        end
      end

      # ==

      class Primitivesque_As_Component___  # #stowaway

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

      # ==
end
