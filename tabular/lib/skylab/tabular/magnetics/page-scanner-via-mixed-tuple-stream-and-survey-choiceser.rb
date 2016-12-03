module Skylab::Tabular

  class Magnetics::PageScanner_via_MixedTupleStream_and_SurveyChoiceser

    # the client can know whether or not any "current page" is the last
    # page (ever) without us having to keep two entire pages in memory.

    # likewise we track internally whether this is the first page ever,
    # and we pass this boolean to the page building function.

    class << self
      alias_method :call, :new
      alias_method :[], :call
      undef_method :new
    end  # >>

    # -
      def initialize mixed_tuple_st, survey_choices

        mt = mixed_tuple_st.gets
        if mt
          @_mixed_tuple_on_deck = mt
          @_mixed_tuple_stream = mixed_tuple_st
          @_survey_choices = survey_choices
          __initialize_normally
        else
          @no_unparsed_exists = true
          freeze
        end
      end

      def __initialize_normally

        page_size = @_survey_choices.page_size
        0 < page_size || self._SANITY
        @__page_size = page_size

        _ = @_survey_choices.page_magnetic_function
        _ ||= Home_::Magnetics::PageSurvey_via_MixedTupleStream
        @__page_function = _

        @_gets_one_page = :__gets_first_page_ever
        @no_unparsed_exists = false
      end

      # -- read

      def gets_one
        send @_gets_one_page
      end

      def __gets_first_page_ever
        @_is_first_page = true
        @_gets_one_page = :__gets_second_page_ever
        _gets_one_page_universal
      end

      def __gets_second_page_ever
        @_is_first_page = false
        @_gets_one_page = :_gets_one_page_universal
        _gets_one_page_universal
      end

      def _gets_one_page_universal

        @_user_tuple_countdown = @__page_size

        @_gets_one_mixed_tuple = :__gets_one_mixed_tuple

        _use_mixed_tuple_stream = Common_.stream do
          send @_gets_one_mixed_tuple
        end

        @__page_function[ @_is_first_page, @_survey_choices, _use_mixed_tuple_stream ]
      end

      def __gets_one_mixed_tuple

        @_user_tuple_countdown -= 1

        mt = @_mixed_tuple_stream.gets
        if mt
          x = @_mixed_tuple_on_deck
          @_mixed_tuple_on_deck = mt

          if @_user_tuple_countdown.zero?
            @_gets_one_mixed_tuple = :_nothing
          end
        else
          x = __when_at_end_of_user_stream
        end

        x
      end

      def __when_at_end_of_user_stream

        # (you still have the one tuple on deck to result in, no matter what)
        x = remove_instance_variable :@_mixed_tuple_on_deck

        end_hook = @_survey_choices.hook_for_end_of_mixed_tuple_stream

        if end_hook
          __transition_state_for_end_of_stream_hook end_hook
        else
          _close
        end
        x
      end

      def __transition_state_for_end_of_stream_hook end_hook

        omg_st = end_hook[ :_nothing_for_now_from_tab_ ]
        if omg_st
          @__freewheelin_mixed_tuple_stream = omg_st
          @_gets_one_mixed_tuple = :__gets_freewheelin_tuple
        else
          _close
        end
        NIL
      end

      def __gets_freewheelin_tuple
        mt = @__freewheelin_mixed_tuple_stream.gets
        if mt
          mt
        else
          _close
          NOTHING_
        end
      end

      def _close
        @no_unparsed_exists = true
        remove_instance_variable :@_gets_one_page
        @_gets_one_mixed_tuple = :_nothing
        freeze
      end

      def _nothing
        NOTHING_
      end

      attr_reader(
        :no_unparsed_exists,
      )
    # -

    # ==

    EMPTY_P_ = -> { NOTHING_ }
  end
end
# #history: outgrew core file when it went from stream to scanner
