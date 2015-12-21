module Skylab::Autonomous_Component_System

  # ->

    module For_Interface  # notes in [#003]

      class Read_or_write < Callback_::Actor::Dyadic

        # #open :[#003]:issue-1: this effects a "crude autovivification" -
        # it builds a component for a missing member and stores it whether
        # or not it is ultimately necessary. we would like for it to work
        # like it does thru signals where it only sets the member when it
        # changes (etc), but this will be tricky; and we don't need it yet
        # in the "real world" anyway

        def initialize asc, acs
          @ACS = acs
          @asc_ = asc
        end

        def execute

          if @asc_.model_classifications.looks_primitivesque
            self.__WRITE_ME_cover_me_via_primitive
          else
            ___when_entitesque
          end
        end

        def ___when_entitesque

          qkn = ACS_::Reflection_::Read[ @asc_, @ACS ]

          if qkn.is_effectively_known

            self._REVIEW_one
            qkn.value_x
          else
            Build_and_attach[ @asc_, @ACS ]
          end
        end
      end

      class Touch < Callback_::Actor::Dyadic

        def initialize qkn, acs
          @ACS = acs
          @qkn = qkn
        end

        def execute

          @_asc = @qkn.association

          if @_asc.model_classifications.looks_primitivesque
            __when_primitivesque
          else
            __when_entitesque
          end
        end

        def __when_primitivesque

          if @_asc.has_operations  # contrast with #here ..
            ___when_primitivesque_with_operations
          else
            NIL_  # as covered
          end
        end

        def ___when_primitivesque_with_operations

          ACS_::For_Interface::Primitivesque.new @qkn, @ACS
        end

        def __when_entitesque

          if @qkn.is_effectively_known

            self._REVIEW_two
            @qkn.value_x

          else
            ACS_::Interpretation::Build_empty_hot[ @_asc, @ACS ]
          end
        end
      end

      Build_and_attach = -> asc, acs do
        cmp = ACS_::Interpretation::Build_empty_hot[ asc, acs ]
        ACS_::Interpretation_::Write_value[ cmp, asc, acs ]
        cmp
      end

      To_stream = -> acs do

        if acs.respond_to? :to_stream_for_component_interface
          acs.to_stream_for_component_interface
        else
          Infer_stream[ acs ]
        end
      end

      Infer_stream = -> acs do

        # hand-write a map-reduce stream whereby for all entries of category
        # `operation` and for those entries of category `association` whose
        # component association states or implies an intent of `interface`,
        # produce a qualified knownness-like structure.

        # build the bound reader (one per category) lazily, only when the
        # ACS is found to define one or more entries of that category.

        asc_for = nil ; qkn_for = nil
        entry = nil

        association = -> do
          asc = asc_for[ entry.name_symbol ]
          int = asc.intent
          if ! int || Is_interface_intent___[ int ]
            qkn = qkn_for[ asc ]
            if qkn.is_effectively_known
              if asc.model_classifications.looks_primitivesque

                # in contrast with :#here, we are not placing importance on
                # whether the thing has operations. why this is is not clear
                # .. TODO - try to take it off off the other one

                # WAS: if asc.has_operations. now covered not to by [ze]

                _ = ACS_::For_Interface::Primitivesque.new qkn, acs

                qkn.new_with_value _
              else
                qkn
              end
            else
              qkn
            end
          end
        end

        h = {}

        h[ :association ] = -> do

          asc_for = Component_Association.reader_for acs
          qkn_for = ACS_::Reflection_::Reader[ acs ]
          h[ :association ] = association
          association.call
        end

        h[ :operation ] = -> do

          operation_for = ACS_::Operation.reader_for acs

          p = -> do
            operation_for[ entry.name_symbol ]
          end

          h[ :operation ] = p
          p.call
        end

        st = ACS_::Reflection_::To_entry_stream[ acs ]

        Callback_.stream do  # (hand-written map-reduce for clarity)
          begin

            entry = st.gets
            entry or break

            qkn_ish = h.fetch( entry.category ).call
            qkn_ish or redo
            break

          end while nil

          qkn_ish
        end
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
