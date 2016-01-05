module Skylab::Zerk

  module View_Controllers_::Location

    class << self

      def default_instance
        Placeholder_proc___
      end

      def common_instance
        Common_Instance___
      end
    end  # >>

    Placeholder_proc___ = -> params do
      stack = params.stack
      -> y do
        if 1 == stack.length
          y << '«at root of stack»'
        else
          y << '«at non-root of stack!»'
        end
      end
    end

    class Common_Instance___

      class << self
        alias_method :[], :new
        private :new
      end  # >>

      def initialize params
        @expression_agent = params.expression_agent
      end

      def call y
        y << "«loco»"
      end
    end
  end
end
