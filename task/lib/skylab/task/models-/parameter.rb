class Skylab::Task

  module Models_::Parameter

    class DependeeReference

      def initialize sym
        @sym = sym
        @_sym = :"__#{ sym }__Parameter__"
      end

      def dereference_against_ index

        index.cache_box.touch @_sym do
          ___build_against index
        end
      end

      def ___build_against index

        Parameter_Task__.new @_sym, @sym, & index.on_event_selectively
      end
    end

    class DependeeReference_via_Attribute

      def initialize atr
        @_atr = atr
      end

      def dereference_against_ index

        k = :"__#{ @_atr.name_symbol }__Parameter__"

        index.cache_box.touch k do
          ___build_against k, index
        end
      end

      def ___build_against k, index

        pt = Parameter_Task__.new k, @_atr.name_symbol, & index.on_event_selectively
        pt._FORMAL_ATTRIBUTE_ = @_atr
        pt
      end
    end

    class Parameter_Task__

      # a parameter task is a custom task that models the resolution of a
      # single parameter that is { required -OR- merely accepted } by a
      # node or nodes somewhere in the task graph.
      #
      # (since different nodes can accept the same parameter but some may
      # require it and other may not; each node-parameter requiredmet gets
      # its own subject instance.)
      #
      # like how a common task tries to execute and then succeeds or fails;
      # this task executes and succeeds or fails based on a function of
      # whether the parameter value is effectively known and whether it is
      # required.
      #
      # this class is hard-coded to have a single dependee: the magic
      # task defined next below.

      def initialize sym_, sym, & p

        @_FORMAL_ATTRIBUTE_ = nil

        @name_symbol = sym_
        @_oes_p = p
        @_parameter_symbol = sym
      end

      attr_writer(
        :_FORMAL_ATTRIBUTE_,
      )

      def accept index, & visit

        visit.call self do

          _one = index.cache_box.touch MAGIC_SYMBOL__ do
            Parameters_Source_Proxy___.new
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

        bx = @_PARAMETERS_.parameter_box  # can be nil
        if bx
          had_box = true
          x = bx[ @_parameter_symbol ]
        end

        atr = @_FORMAL_ATTRIBUTE_  # can be nil
        if atr
          if ! Field_::Is_required[ atr ]
            is_optional = true
          end
        end

        # --

        if x.nil?
          if is_optional
            @_value_x = x ; ACHIEVED_  # even when known unknown
          else
            ___when_missing_required had_box, atr
          end
        else
          @_value_x = x ; ACHIEVED_
        end
      end

      def ___when_missing_required had_box, atr

        # (this could be tighter if we used etc.. [#006])

        name = -> do
          if atr
            atr.name
          else
            Callback_::Name.via_variegated_symbol @_parameter_symbol
          end
        end

        express = -> do
          if ! had_box
            _and = " (had no parameters at all)"
          end
          "missing required parameter #{ par name[] }#{ _and }"
        end

        oes_p = @_oes_p
        if oes_p
          oes_p.call :error, :expression do |y|
            y << calculate( & express )
          end
          UNABLE_
        else
          _expag = Home_.lib_.brazen::API.expression_agent_instance
          _s = _expag.calculate( & express )
          raise ::ArgumentError, _s
        end
      end

      def derived_ivar_
        @___derived_ivar ||= :"@#{ @_parameter_symbol }"
      end

      attr_reader(
        :_FORMAL_ATTRIBUTE_,
        :name_symbol,
      )
    end

    class Parameters_Source_Proxy___

      def name_symbol
        MAGIC_SYMBOL__
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
    MAGIC_SYMBOL__ = :_PARAMETERS_
  end
end
