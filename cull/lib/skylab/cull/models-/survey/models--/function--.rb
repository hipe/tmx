module Skylab::Cull

  class Models_::Survey

    class Models__::Function__

      def initialize survey, & oes_p
        @survey = survey
        @_emit = oes_p
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

        arg.value.each do |s|
          ok = __parse s
          ok or break
          ok = send m, ok
          ok or break
        end

        ok
      end

      def __parse s
        Home_::Models_::Function_.unmarshal_via_string_and_module(
          s,
          my_box_module,
          & @_emit )
      end

      def _report_associated_entity
        @survey.touch_associated_entity_ :report
      end
    end

    class Models__::Map < Models__::Function__
    private

      def my_box_module
        Home_::Models_::Map::Items__
      end
    end

    class Models__::Mutator < Models__::Function__
    private

      def my_box_module
        Home_::Models_::Mutator::Items__
      end
    end

    class Models__::Aggregator < Models__::Function__
    private

      def my_box_module
        Home_::Models_::Aggregator::Items__
      end
    end
  end
end
