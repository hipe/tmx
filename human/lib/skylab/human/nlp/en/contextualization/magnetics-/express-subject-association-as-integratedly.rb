module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Express_Subject_Association_as_Integratedly

      # crutch.

      class << self

        def modify_contextualization_client_ o, meaning, collection  # o = c15n

          if o.state_crutch_
            o.begin_customization_ collection
          end

          o.must_read :channel
          o.must_read :expression_agent
          o.must_read :selection_stack
          o.must_read :string
          o.can_read :three_parts_of_speech
          o.must_read :trilean

          o.push_function_ :Three_Parts_Of_Speech_via_Selection_Stack

          o.push_function_ :Trilean_via_Channel  # EEW

          NIL_
        end
      end  # >>

      This_ = self
    end
  end
end
# #history: born expecting to be temporary
