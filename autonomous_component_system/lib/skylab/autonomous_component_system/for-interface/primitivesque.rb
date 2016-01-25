module Skylab::Autonomous_Component_System

  module For_Interface  # notes in [#003]

    class Primitivesque

      # (for now this module is public b/c we are anticipating adding
      # public library functions to it)

      # the component model models a component that is primitive-esque
      # (that is, the model looks like a proc). when it was evaluated the
      # component association defined one or more operations. the actual
      # value for the component may be a known unknown. make it look like a
      # compound component with operations EEK!

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

      def component_value_reader_for_reactive_tree
        -> qkn do
          self._K
        end
      end

      # (used to have ..)

      def wrapped_qualified_knownness
        @_qkn
      end
    end
  end
end
