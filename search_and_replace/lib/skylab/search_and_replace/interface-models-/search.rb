module Skylab::SearchAndReplace

  class Interface_Models_::Search

    # #frontier(s) here (and prototyping eyeblood):
    #
    #   • there are [0..] "dynamic compounds" - each such one's associations
    #     are determined entirely at "runtime" (as opposed to by method
    #     definitions)
    #
    #   • there are [0..] "component as model"s - each such one defines
    #     instance methods that are usually defined as methods on the class
    #     of same. it's a "hybrid" ..

    def initialize comp_a, & oes_p

      # what interface nodes are active are determined from above.
      # #todo is it as open issue that this might go stale & out of sync w/
      # UI, but we can't cover that until much later..

      @_component_a = comp_a
      @_oes_p = oes_p
    end

    # .. you want it to look like a *compound* node so the parser recurses ..

    def interpret_compound_component p, & _oes_p_p
      p[ self ]
    end

    def to_stream_for_component_interface

      _st = Callback_::Stream.via_nonsparse_array @_component_a

      _st.map_by do | component |

        _nf = component.name_

        _asc = ACS_::Component_Association.via_name_and_model(
          _nf, component )

        Callback_::Qualified_Knownness.via_value_and_association(
          component, _asc )
      end
    end

    Require_ACS_[]
  end
end
