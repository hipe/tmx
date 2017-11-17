module Skylab::Arc

  class Magnetics::TouchComponent_via_Association_and_FeatureBranch

    # #open [#008.D] - make it a magnetic by simple model
    # result is a qk-ish

        # 1) by default when we create a new component value for these ones,
        #    we "attach" that value to the ACS (for example, by writing to
        #    the ivar) but this attaching can be disabled thru an option.
        #    when this attaching of the new component is disabled, we refer
        #    to the resulting component as "floating".
        #
        # 2) (see the reference to [#010] below)
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
        # (see just above the `[]` instance method below.) (hi.)
      end  # >>

      def initialize
          @do_attach = true
      end

      def component_association= x
        @_asc = x
      end

      attr_writer(
        :do_attach,
        :reader_writer,
      )

      def self.[] asc, rw
        o = new
        o.component_association = asc
        o.reader_writer = rw
        o.execute
      end

      def [] asc, rw
        o = dup
        o.component_association = asc
        o.reader_writer = rw
        o.execute
      end

      def execute

        @_qk = @reader_writer.qualified_knownness_of_association @_asc

        @_is_known = @_qk.is_effectively_known

        if @_asc.model_classifications.looks_primitivesque
          __when_primitivesque
        elsif @_is_known
          # #open [#se-034] #cover-me
          @_qk
        else
          ___when_unknown_nonprimitivesque
        end
      end

      def ___when_unknown_nonprimitivesque

        # (an only slightly modified version of "build and attach" below.)

        qk = Build_empty_hot___[ @_asc, @reader_writer.ACS_ ]
        if @do_attach
          @reader_writer.write_value qk
        end
        qk
      end

      def __when_primitivesque

        bx = @_asc.transitive_capabilities_box
        _has_transitive_capabilities = bx && bx.length.nonzero?

        if _has_transitive_capabilities
          Primitivesque_Wrapper___.new @_qk, @ACS
        else
          NOTHING_  # as covered
        end
      end

      Build_empty_hot___ = -> asc, acs do  # result is qk

        _p_p = Home_::Magnetics_::EmissionHandlerBuilder_via_Association_and_ACS[ asc, acs ]

        o = Home_::Magnetics::QualifiedComponent_via_Value_and_Association.begin nil, asc, acs, & _p_p

        o.mixed_argument = if o.looks_like_compound_component__
          IDENTITY_
        else
          Common_::THE_EMPTY_SCANNER
        end

        o.execute
      end

      class Primitivesque_Wrapper___

        # #open [#010] this is so [etc])

        def initialize qkn, acs

          @ACS = acs
          @_qkn = qkn
        end

        def describe_into_under y, expag

          p = @_qkn.association.instance_description_proc

          if p
            expag.calculate y, & p
          else
            y
          end
        end

        # (used to have ..)

        def wrapped_qualified_knownness
          @_qkn
        end
      end
  end
end
