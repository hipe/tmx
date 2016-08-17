module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Express_Selection_Stack_as_Nestedly

      class << self

        def modify_contextualization_client_ o, _manner, collection  # o = c15n

          o.begin_customization_ collection

          o.can_read :channel
          o.must_read :expression_agent
          o.can_read :lemmas
          o.must_read :precontextualized_line_streamer
          o.can_read :selection_stack
          o.must_read :trilean

          NIL_
        end
      end
    end
  end
end
# #tombstone: removed hints
# #history: this sort of thin "hinting" node is perhaps temporary
