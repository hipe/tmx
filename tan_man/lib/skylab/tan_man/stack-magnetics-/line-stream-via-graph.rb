module Skylab::TanMan

  class StackMagnetics_::LineStream_via_Graph < Common_::Actor::Monadic

    def initialize g

    end

    def execute
      @_method = :__open
      Common_.stream do
        send @_method
      end
    end

    def __open
      @_method = :__first_body_line
      "digraph g {\n"
    end

    def __first_body_line
      @_method = :__last_line
      "  a->b\n"
    end

    def __last_line
      @_method = :__done
      "}\n"
    end

    def __done
      NOTHING_
    end

    NOTHING_ = nil
  end
end
