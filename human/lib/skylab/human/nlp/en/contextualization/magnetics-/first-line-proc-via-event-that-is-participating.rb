module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::First_Line_Proc_via_Event_that_Is_Participating ; class << self

      # go this away eventually ([#043]."B")

      def via_magnetic_parameter_store ps

        x = ps.trilean

        if x
          ev = ps.event
          if ev.has_member :is_completion and ev.is_completion
            _is_comp = true
          end
          if _is_comp
            Magnetics_::First_Line_Proc_via_Event_that_Is_Completion
          else
            Magnetics_::First_Line_Proc_via_Event_that_Is_Success
          end
        elsif x.nil?
          First_Line_Proc_via_Event_that_Is_Neutral___
        else
          Magnetics_::First_Line_Proc_via_Event_that_Is_Failure
        end
      end

      alias_method :[], :via_magnetic_parameter_store

      # ==

      module First_Line_Proc_via_Event_that_Is_Neutral___

        def self.mutate_line_contextualization_ _, __
          NOTHING_
        end
      end
    end ; end
  end
end
# #history: broke out of "expression via emission"
