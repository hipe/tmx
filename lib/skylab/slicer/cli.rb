module Skylab::Slicer

  class CLI < Brazen_::CLI

    class << self
      def new * a
        new_top_invocation a, Home_.application_kernel_
      end
    end  # >>

    def expression_agent_class
      self.class.superclass::Expression_Agent
    end

    def self.unbound_for_face _
      self
    end
  end
end
