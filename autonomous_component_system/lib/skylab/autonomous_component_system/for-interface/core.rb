module Skylab::Autonomous_Component_System

  # ->

    module For_Interface  # notes in [#003]

      To_stream = -> acs do

        if acs.respond_to? :to_stream_for_component_interface
          acs.to_stream_for_component_interface
        else
          Infer_stream[ acs ]
        end
      end

      class Infer_stream < Callback_::Actor::Monadic

        # hand-write a map-reduce stream whereby for all entries of category
        # `operation` and for those entries of category `association` whose
        # component association states or implies an intent of `interface`,
        # produce a qualified knownness-like structure.

        # build the bound reader (one per category) lazily, only when the
        # ACS is found to define one or more entries of that category.

        def initialize acs
          @ACS = acs

          @_qkn_for_category = {
            association: method( :__qkn_for_first_association ),
            operation: method( :__qkn_for_first_operation ),
          }
        end

        def execute

          st = Home_::Reflection_::To_entry_stream[ @ACS ]

          Callback_.stream do  # (hand-written map-reduce for clarity)
            begin

              entry = st.gets
              entry or break

              qkn_ish = @_qkn_for_category.fetch( entry.category ).call entry
              qkn_ish or redo
              break

            end while nil

            qkn_ish
          end
        end

        def __qkn_for_first_association first_entry

          asc_for = Component_Association.reader_for @ACS
          @_qkn_for = Home_::Reflection_::Reader[ @ACS ]

          p = -> entry do

            asc = asc_for[ entry.name_symbol ]
            if asc
              int = asc.intent  # #during [#018]
              if ! int || Is_interface_intent___[ int ]
                ___via_interface_association asc
              end
            else
              NIL_  # conditionally turn a whole assoc. off [sa]
            end
          end

          @_qkn_for_category[ :association ] = p

          p[ first_entry ]
        end

        def ___via_interface_association asc  # compare to here-A

          qk = @_qkn_for[ asc ]
          if qk.is_effectively_known
            if asc.model_classifications.looks_primitivesque
              self._NOT_UNTIL_during_milestone_2
              Home_::For_Interface::Primitivesque.new qk, @ACS
            else
              qk
            end
          else
            qk
          end
        end

        def __qkn_for_first_operation first_entry

          operation_for = Home_::Operation.reader_for @ACS

          p = -> entry do
            operation_for[ entry.name_symbol ]
          end

          @_qkn_for_category[ :operation ] = p

          p[ first_entry ]
        end
      end

      class Touch < Callback_::Actor::Dyadic  # result is a qk-ish

        # 1) by default when we create a new component value for these ones,
        #    we "attach" that value to the ACS (for example, by writing to
        #    the ivar) but this attaching can be disabled thru an option.
        #    when this attaching of the new component is disabled, we refer
        #    to the resulting component as "floating".
        #
        # 2) because this is "for interface", for primitives you
        #    get a wrapper IFF [..]
        #    NOTE that for now, we never "attach" a primitive (because
        #    we never create one)
        #
        # (all knowns/unknowns are "effectively":)
        #
        # if known   comp then qk of existing comp
        # if known   ent  then qk of existing ent
        # if known   prim then (2)
        # if unknown comp then qk of created comp (1)
        # if unknown ent  then qk of created ent (1)
        # if unknown prim then (2)

        class << self
          public :new
        end  # >>

        def initialize asc, acs
          @do_attach = true
          _init_via asc, acs
        end

        attr_writer(
          :do_attach,
        )

        def [] asc, acs
          dup._init_via( asc, acs ).execute
        end

        def _init_via asc, acs
          @ACS = acs
          @asc = asc
          self
        end

        def execute  # compare to here-A

          @_qk = Home_::Reflection_::Read[ @asc, @ACS ]
          @_is_known = @_qk.is_effectively_known

          if @asc.model_classifications.looks_primitivesque
            __when_primitivesque
          elsif @_is_known
            self._COVER_ME_probably_fine
            @_qk
          else
            ___when_unknown_nonprimitivesque
          end
        end

        def ___when_unknown_nonprimitivesque

          # (an only slightly modified version of `Build_and_attach` below.)

          qk = Home_::Interpretation::Build_empty_hot[ @asc, @ACS ]
          if @do_attach
            Home_::Interpretation_::Write_value[ qk.value_x, @asc, @ACS ]
          end
          qk
        end

        def __when_primitivesque

          bx = @asc.transitive_capabilities_box
          _has_transitive_capabilities = bx && bx.length.nonzero?

          if _has_transitive_capabilities
            ACS_::For_Interface::Primitivesque.new @_qk, @ACS
          else
            NOTHING_  # as covered
          end
        end
      end

      Build_and_attach = -> asc, acs do  # result is qk
        qk = Home_::Interpretation::Build_empty_hot[ asc, acs ]
        Home_::Interpretation_::Write_value[ qk.value_x, asc, acs ]
        qk
      end

      Is_interface_intent___ = {
        # (etc..)
        interface: true,
        API: true,
        UI: true,
      }.method :[]

    end
  # -
end
