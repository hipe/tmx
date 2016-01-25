module Skylab::Autonomous_Component_System

  # ->

    module For_Interface  # notes in [#003]

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

    end
  # -
end
