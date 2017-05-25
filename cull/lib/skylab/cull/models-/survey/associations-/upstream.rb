module Skylab::Cull

  class Models_::Survey

    module Models__::Upstream

      MODEL_CONST = :Upstream

      IS_SINGLETON_ASSOCIATION = true

      class WriteComponent_via_Component_and_Survey < Common_::Dyadic

        def initialize qc, survey, & p
          @upstream = qc.value
          @association = qc.association
          @survey = survey
          @listener = p
        end

        def execute
          if __write_to_survey
            __emit_event
            ACHIEVED_
          end
        end

        def __emit_event

          _ev = @upstream.to_descriptive_event  # #todo

          @listener.call :info, :set_upstream do
            _ev
          end

          NIL
        end

        def __write_to_survey

          _st = @upstream.to_persistable_primitive_name_value_pair_stream_recursive_ @survey

          _ok = @survey.write_component_via_primitives_by__ do |o|
            o.primitive_name_value_stream_recursive = _st
            o.association_name_symbol = @association.name_symbol
            o.listener = @listener
          end

          _ok  # hi. #todo
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
      end

      # ==

      # ==
      # ==
    end
  end
end
# #history-A.1: start to inject ween-off-[br] stuff
