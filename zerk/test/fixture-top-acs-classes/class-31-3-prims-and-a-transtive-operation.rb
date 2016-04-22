module Skylab::Zerk::TestSupport

  class Fixture_Top_ACS_Classes::Class_31_3_Prims_and_a_Transtive_Operation

    # NOTE - this was the 3rd-ish added fixture-graph. are we getting rid of
    # expression for for "transitive operations" in the iCLI? we want to. if
    # so we should rename and rework this so that they don't occur here. OR
    # we could keep them to assert that they are inert in the iCLI..

    # (this is named "zombies" because we had just seen mockingjay p.2..)

    # model an ACS with three components, each leaf-like. the first and
    # third components have no specially defined operations, so a "set"-
    # like operation is assumed. the second component has two simply-defined
    # operations. `set` is a special operation name here - it will effect
    # the same UI mechanics used for the assumed "set" operations (experimental).
    # all other operations besides `set` need the ACS to define the operation
    # explicitly, as we have done here with `delete`.

    def initialize
      # #cold-model (no more event handler inside)
    end

    def __fozzer__component_association

      All_caps_primitivesque_
    end

    def __fizzie_nizzie__component_association

      yield :can, :set, :delete

      All_caps_primitivesque_
    end

    def __biz_nappe__component_association

      All_caps_primitivesque_
    end

    def __delete__component asc, & pp

      self._README  # all of this would change for #cold-model (and no transitive operations)

      _ = "pretending to delete '#{ asc.name.as_slug }'"

      pp[ nil ].call :info, :expression do |y|
        y << "#{ _ } two"
      end

      :_yep_
    end

    rx = /\A\Z|[^A-Z]/m  # the empty string or any char other than A-Z, is invalid

    All_caps_primitivesque_ = -> st, & pp do
      s = st.current_token
      md = rx.match s
      if md
        pp[ nil ].call :error, :expression, :not_all_caps do |y|
          y << "string must be in all caps (had: #{ ick md[ 0 ] })"
        end
        UNABLE_
      else
        st.advance_one
        Callback_::Known_Known[ s ]
      end
    end
  end
end
# #pending-rename: see note in first comment in this file
