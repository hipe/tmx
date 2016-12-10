module Skylab::Tabular

  class Magnetics::PageScanner_via_MixedTupleStream_and_SurveyChoiceser

    # produce a "minimal scanner" (i.e an object that exposes only
    # `no_unparsed_exists` and `gets_one`).
    #
    # the second argument is a proc-like that produces each next page-
    # survey-choices to be used for each page-survey that is produced.
    # (because each call to this proc-like produces a "choices", we may call
    # it a "choiceser" - them's the rules.)
    #
    # this proc is guaranteed to be called in lockstep with each page: it
    # will be called once for each page that is to be made, and it will
    # never be called extraneously.
    #
    #
    # ## about it
    #
    # this is designed around the assumed requirement that the client must
    # know if any given page is the last page in the invocation (probably to
    # implement a hook; probably for summary rows). in this regard the
    # client needs a sort of "lookahead" to know whether after any current
    # item, there exists another item.
    #
    # the relevant difference between a "scanner" and a "stream" is that of
    # lookahead: the scanner exposes a method dedicated to reporting whether
    # it is empty (in a manner that does not change its state) whereas the
    # stream has no such method. (if a stream were to have such a method, it
    # would by definition be a scanner.)
    #
    # if the client were to need to know if any given page is the last and
    # she had a stream (not scanner) of pages, then she would only be able
    # to discover this by requesting a *next* page from the stream. if such
    # a page were produced, she would then need to hold both pages in memory,
    # increasing the memory requirement of context-aware paging like this by
    # 2x. as such, we model the subject as a scanner (not stream) to avoid
    # this memory hit.
    #
    # internally this memory savings isn't totally without cost: because the
    # upstream is itself a minimal stream (i.e it responds only to `gets`
    # as far as we know) and not a scanner, we implement a "hard peek" by
    # storing up to one mixed tuple in memory. (we call it the "on deck"
    # item.) we use the knowlege of whether we have an "on deck" item to
    # tell us whether any given page is the last. it is the same idea as the
    # egregious case described above, except that we are only storing one
    # extra item in memory instead of a whole page of items.

    class << self
      def call mt_st, er
        mt = mt_st.gets
        if mt  # :#here
          new mt, er, mt_st
        else
          Common_::Polymorphic_Stream.the_empty_polymorphic_stream
        end
      end
    end  # >>

    # -

      def initialize mt, er, mt_st
        @_gets_one = :__gets_first_one
        @mixed_tuple_stream = mt_st
        @_no_unparsed_exists = -> { UNABLE_ }  # NILADIC_FALSESHOOD_
        @_on_deck = mt
        @__survey_choiceser = er
        @was_first_page = true
      end

      def gets_one
        send @_gets_one
      end

      def __gets_first_one
        @_gets_one = :__gets_first_subsequent_one
        _normally
      end

      def __gets_first_subsequent_one
        @was_first_page = false
        @_gets_one = :_normally
        send @_gets_one
      end

      def _normally

        _item_on_deck = remove_instance_variable :@_on_deck
        survey_cx = @__survey_choiceser.call

        cs = MinimalStreamPlusTwoMethods___.new(
          _item_on_deck, @mixed_tuple_stream, survey_cx )

        @_no_unparsed_exists = cs.method :__exhausted_naturally_

        page = Home_::Magnetics::PageSurvey_via_MixedTupleStream.call(
          @was_first_page, survey_cx, cs )

        if @_no_unparsed_exists.call
          remove_instance_variable :@_gets_one
        else
          @_on_deck = cs.__item_on_deck_
        end

        page
      end

      def no_unparsed_exists
        @_no_unparsed_exists.call
      end

      attr_reader(
        :was_first_page,
      )
    # -
    # ==

    class MinimalStreamPlusTwoMethods___

      # mainly a minimal stream (i.e responds only to `gets` ) that produces
      # each next mixed tuple stream. but also 2 other methods (below).
      #
      # chain together these responsibilities:
      #
      #   - undo the peek we do #here of seeing if there's any first tuple
      #
      #   - realize limiting (paging)
      #
      #   - realize any hook at the end of the page
      #
      # if the above were our only responsibilities, we could accompish
      # this with a chain of three simple familiar stream constructs (we did)
      # rather than one ad-hoc dedicated class. but also, expose this:
      #
      #   - did we end because we hit the limit, or did we end
      #     because we ran out of items?
      #
      #   - because our argument stream is a zero-lookahead ("minimal")
      #     stream, we must distinguish the above by peeking. we then need
      #     to expose a way to release the item we peeked for the next
      #     stream (page) to contain.

      def initialize item_on_deck, mixed_tuple_st, survey_choices

        page_size = survey_choices.page_size

        0 < page_size || self._NEEDS_THOUGHT
        zero = -> do
          countdown = page_size
          -> do
            countdown -= 1
            countdown.zero?
          end
        end.call

        at_end = nil

        @_gets_tuple = -> do
          x = item_on_deck
          item_on_deck = mixed_tuple_st[]
          if item_on_deck
            if zero[]
              @_exhausted_naturally_known = Common_::Known_Known.falseish_instance
              @__item_on_deck_known = Common_::Known_Known[ item_on_deck ]
              at_end[]
            end
          else
            @_exhausted_naturally_known = Common_::Known_Known.trueish_instance
            at_end[]
          end
          x
        end

        close = -> do
          @_gets_tuple = EMPTY_P_
        end

        end_hook = survey_choices.hook_for_end_of_mixed_tuple_stream
        at_end = if end_hook
          -> do
            omg_st = end_hook[ :_nothing_for_now_from_tab_ ]
            if omg_st
              @_gets_tuple = omg_st.method :gets
            else
              close[]
            end
          end
        else
          close
        end
      end

      def gets
        @_gets_tuple.call
      end

      def __exhausted_naturally_
        @_exhausted_naturally_known.value_x
      end

      def __item_on_deck_
        @__item_on_deck_known.value_x
      end
    end

    # ==

    # ==
  end
end
# #history: outgrew core file when it went from stream to scanner
