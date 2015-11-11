module Skylab::Brazen

  module Autonomous_Component_System

    module For_Interface  # notes in [#083]

      class Common_Three__  # (experiment)

        class << self

          def _call asc, acs, & oes_p
            new( asc, acs, & oes_p ).execute
          end

          alias_method :[], :_call

          alias_method :call, :_call

        end  # >>

        def initialize asc, acs, & oes_p
          @ACS = acs
          @asc_ = asc
          @oes_p_ = oes_p
        end
      end

      class Read_or_write < Common_Three__

        # #open :[#083]:issue-1: this effects a "crude autovivification" -
        # it builds a component for a missing member and stores it whether
        # or not it is ultimately necessary. we would like for it to work
        # like it does thru signals where it only sets the member when it
        # changes (etc), but this will be tricky; and we don't need it yet
        # in the "real world" anyway

        def execute

          if @asc_.model_looks_like_proc
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
            ___build_new_empty_entitesque
          end
        end

        def ___build_new_empty_entitesque

          cmp = Upbind__[ @asc_, @ACS, & @oes_p_ ]
          ACS_::Interpretation_::Write_value[ cmp, @asc_, @ACS ]
          cmp
        end
      end

      class Touch < Common_Three__

        def execute

          @_qkn = ACS_::Reflection_::Read[ @asc_, @ACS ]

          if @asc_.model_looks_like_proc  # start logic that is repeated #here
            __when_primitivesque
          else
            __when_entitesque
          end
        end

        def __when_primitivesque

          if @asc_.has_operations
            ___when_primitivesque_with_operations
          else
            NIL_  # as covered
          end
        end

        def ___when_primitivesque_with_operations

          Here_::Primitivesque.new @_qkn, @ACS
        end

        def __when_entitesque

          if @_qkn.is_effectively_known

            self._REVIEW_two
            @_qkn.value_x

          else

            Upbind__[ @asc_, @ACS, & @oes_p_ ]
          end
        end
      end

      Upbind__ = -> asc, acs, & oes_p do

        # create a new empty component that is bound to the client,
        # but is *NOT* (yet) stored as a member value of client!

        o = ACS_::Interpretation_::Build_Value.new( asc, acs, & oes_p )

        o.use_empty_argument_stream

        o.wrap_handler_as_component_handler

        wv = o.execute

        wv && wv.value_x
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

        known_qkn = -> qkn do  # repetition of :#here
          asc = qkn.association
          if asc.model_looks_like_proc
            if asc.has_operations

              _ = Here_::Primitivesque.new qkn, acs

              qkn.new_with_value _
            else
              NIL_
            end
          else
            qkn
          end
        end

        asc_for = nil ; qkn_for = nil
        entry = nil

        association = -> do
          asc = asc_for[ entry.name_symbol ]
          int = asc.intent
          if ! int || :interface == int
            qkn = qkn_for[ asc ]
            if qkn.is_known_known
              known_qkn[ qkn ]
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

      Here_ = self
    end
  end
end
