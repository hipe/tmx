module Skylab::Zerk

  class InteractiveCLI

  module Location_ViewController___

    class << self

      def default_instance
        Placeholder_proc___
      end

      def common_instance
        Common_Instance___
      end
    end  # >>

    Placeholder_proc___ = -> _ do

      -> y do
        if _.top_frame.below_frame
          y << '«at non-root of stack!»'
        else
          y << '«at root of stack»'
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
end
