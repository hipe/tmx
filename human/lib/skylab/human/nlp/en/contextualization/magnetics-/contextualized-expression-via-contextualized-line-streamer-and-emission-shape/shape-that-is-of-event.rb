module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Contextualized_Expression_via_Emission_that_Is_Event

      class << self

        def via_magnetic_parameter_store ps
          new( ps ).execute
        end
        alias_method :[], :via_magnetic_parameter_store
        private :new
      end  # >>

      def initialize ps
        @_ps = ps
      end

      def execute

        ps = @_ps

        if ps._magnetic_value_is_known_ :event
          ev = ps.event
          @event = ev
        else
          # (it is probably not known)
          ev = ps.emission_proc.call
          @event = ev
          ps.event = ev
        end

        # for now we weirdly let you specify your own trilean value rather
        # than recognizing that of the event but this is not covered.

        if ! ps._magnetic_value_is_known_ :trilean
          ps.trilean = ev.ok
        end

        # get busy

        if ps._magnetic_value_is_known_ :inflected_parts
          __when_inflected_parts

        elsif ev.has_member :verb_lexeme  # if it's participating
          __when_event_is_participating

        elsif ev.has_member :verb_lemma
          self._OHAI  # #todo

        else
          __when_event_is_not_participating
        end
      end

      def __when_event_is_not_participating

        if _has_downstream_listener_proc
          __re_emit_the_exact_same_event
        else
          _express_these_lines _raw_lines_of_event
        end
      end

      def __re_emit_the_exact_same_event
        @_listen_proc.call( * @_ps.channel ) do
          @event
        end
      end

      def __when_inflected_parts

        __init_pretty_streamer_when_inflected_parts

        _common_dichotomy
      end

      def __init_pretty_streamer_when_inflected_parts

        @_to_pretty_stream = :___to_pretty_stream_when_inflected_parts ; nil
      end

      def ___to_pretty_stream_when_inflected_parts

        @_ps.precontextualized_line_stream = _raw_lines_of_event

        Magnetics_::
          Contextualized_Line_Stream_via_Inflected_Parts_and_Precontextualized_Line_Stream[
            @_ps ]
      end

      def __when_event_is_participating

        __init_pretty_streamer_when_participating_event

        _common_dichotomy
      end

      def __init_pretty_streamer_when_participating_event

        @__mod = Magnetics_::First_Line_Proc_via_Event_that_Is_Participating[ @_ps ]

        @_to_pretty_stream = :___to_pretty_stream_when_participating_event
      end

      def ___to_pretty_stream_when_participating_event

        p = -> lc do  # line contextualization

          @__mod.mutate_line_contextualization_ lc, @event
          NIL_
        end

        _raw_st = _raw_lines_of_event

        Magnetics_::
          Contextualized_Line_Stream_via_First_Line_Proc_and_Precontextualized_Line_Stream.
            call( p, _raw_st )
      end

      # --

      def _common_dichotomy
        if _has_downstream_listener_proc
          __build_and_emit_new_event
        else
          _ = _to_pretty_stream
          _express_these_lines _
        end
      end

      def _has_downstream_listener_proc
        ( @___kn ||= ___listen_kn ).value_x
      end

      def ___listen_kn
        p = @_ps.downstream_selective_listener_proc
        if p
          @_listen_proc = p
          yes = true
        end
        Common_::Known_Known[ yes ]
      end

      def __build_and_emit_new_event

        st_p = method :_to_pretty_stream

        _ev = @event.new_with do |y, _o|
          st = st_p[]
          while line = st.gets
            y << line
          end
          y
        end

        @_listen_proc.call( * @_ps.channel ) do
          _ev
        end
      end

      def _express_these_lines pretty_st

        @_ps.contextualized_line_stream = pretty_st
        Magnetics_::Contextualized_Expression_via_Contextualized_Line_Stream[ @_ps ]
      end

      def _to_pretty_stream
        send @_to_pretty_stream
      end

      def _raw_lines_of_event
        Magnetics_:: Precontextualized_Line_Stream_via_Emission_that_Is_Event[ @_ps ]
      end
    end
  end
end
# #history: born.
