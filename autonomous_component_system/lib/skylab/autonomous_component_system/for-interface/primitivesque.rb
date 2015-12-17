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

      def to_stream_for_component_interface

        _st = @_qkn.association.to_operation_symbol_stream

        _st.map_by do | symmo |

          Operation___.__new symmo, @_qkn, @ACS
        end
      end
    end

    class Operation___ < ACS_::Operation

      class << self
        alias_method :__new, :new
        public :__new
      end

      def initialize sym, qkn, acs

        super acs

        @_qkn = qkn

        init_for_sym_ sym
      end

      def method_and_args_for_ sym

        [ :"__#{ sym }__primitivesque_component_operation_for", @_qkn ]
      end
    end
  end
end
