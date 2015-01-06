module Skylab::Cull

  class Models_::Survey

    class Models__::Mutator

      def initialize survey, & oes_p
        @survey = survey
        @on_event_selectively = oes_p
      end

      def add arg, box
        _batch arg, box, :__add
      end

      def __add func

        _report_associated_entity.add_function_call func

      end

      def remove arg, box
        @_remove_a = []
        _batch arg, box, :__remove and begin
          a = @_remove_a
          @_remove_a = nil
          _report_associated_entity.remove_function_calls a
        end
      end

      def __remove func
        @_remove_a.push func
        ACHIEVED_
      end

      def _batch arg, box, m
        ok = true

        arg.value_x.each do | s |
          ok = __parse s
          ok or break
          ok = send m, ok
          ok or break
        end

        ok
      end

      def __parse s
        Cull_::Models_::Mutator::FUNCTION.unmarshal_via_string_and_module(
          s,
          Models_::Mutator::Items__,
          & @on_event_selectively )
      end

      def _report_associated_entity
        @survey.touch_associated_entity_ :report
      end
    end
  end
end
