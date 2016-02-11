module Skylab::Human::TestSupport

  module NLP::EN::Contextualization

    def self.[] tcc
      tcc.include self
    end

    def common_expag_
      Home_.lib_.brazen::API.expression_agent_instance
    end

    def subject_class_
      Home_::NLP::EN::Contextualization
    end
  end
end
