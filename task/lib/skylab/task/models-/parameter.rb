class Skylab::Task

  Models_ = ::Module.new
  module Models_::Parameter

    class Dependee_Reference

      def initialize sym
        @sym = sym
        @_sym = :"__#{ sym }__Parameter__"
      end

      def dereference_against_ index

        bx = index.box

        bx.fetch @_sym do
          x = __build_against index
          bx.add @_sym, x
          x
        end
      end

      def __build_against index

        Parameter_Task___.new @_sym, @sym, & index.on_event_selectively
      end
    end

    class Parameter_Task___

      # a parameter task is a custom task that models the resolution of
      # a single parameter required (somewhere) by the graph. this class
      # is hard-coded to have a single dependee: the magic task defined
      # next below.

      def initialize sym_, sym, & p

        @name_symbol = sym_
        @_parameter_symbol = sym
        @on_event_selectively = p
      end

      attr_reader :name_symbol

      def accept index, & visit

        visit.call self do

          _one = index.box.fetch MAGIC_SYMBOL do
            x = Parameters_Source_Proxy___.new
            index.box.add MAGIC_SYMBOL, x
            x
          end

          Callback_::Stream.via_item _one
        end
      end

      def visit_dependant_as_completed_ dep, dc

        dep.receive_dependency_completion_value @_value_x, dc
        NIL_
      end

      def receive_dependency_completion o
        instance_variable_set o.derived_ivar, o.task
        NIL_
      end

      def execute

        x = @_PARAMETERS_.parameter_box[ @_parameter_symbol ]
        if x.nil?
          raise ::ArgumentError, __say_required_param_missing
        else
          @_value_x = x
          ACHIEVED_
        end
      end

      def derived_ivar_
        @___derived_ivar ||= :"@#{ @_parameter_symbol }"
      end

      def __say_required_param_missing
        "missing required parameter '#{ @_parameter_symbol }'"
      end
    end

    class Parameters_Source_Proxy___

      def name_symbol
        MAGIC_SYMBOL
      end

      def accept index, & visit
        visit.call self
      end

      def accept_execution_graph__ eg

        @parameter_box = eg.parameter_box
        NIL_
      end

      attr_reader :parameter_box

      def execute
        # (it is our immediate downstream that does the work)
        ACHIEVED_
      end

      def derived_ivar_
        IVAR___
      end
    end

    IVAR___  = :"@_PARAMETERS_"
    MAGIC_SYMBOL = :_PARAMETERS_
  end
end
