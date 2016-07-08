module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::String_via_Subject_Association

      class << self
        def via_magnetic_parameter_store ps
          new( ps ).execute
        end
      end  # >>

      def initialize ps

        @expression_agent = ps.expression_agent
        @subject_association = ps.subject_association
        @_etc_p = ps.to_say_subject_association
      end

      def execute
        p = @_etc_p
        p ||= Express_subject_association___

        # (was 'say_subject_association_by_` #todo)
        @expression_agent.calculate @subject_association, & p
      end

      # ==

      Express_subject_association___ = -> asc do
        nm asc.name
      end
    end
  end
end
# #history: abstracted from a method in what was once "transition"
