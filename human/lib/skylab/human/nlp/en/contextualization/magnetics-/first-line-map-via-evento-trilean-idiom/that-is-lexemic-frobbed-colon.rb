module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::First_Line_Map_via_Evento_Trilean_Idiom::That_Is_Lexemic_Frobbed_Colon ; class << self

      def via_magnetic_parameter_store ps

        # (assume not a wrapped event, a structured event)

        -> line do
          lc = Magnetics_::Line_Contextualization_via_Line[ line ]
          if ps.possibly_wrapped_event.respond_to? :inflected_noun
            __map_line_this_one_way lc, ps
          else
            _map_line_by_doing_colon_thing lc, ps
          end
        end
      end

      alias_method :[], :via_magnetic_parameter_store

      def __map_line_this_one_way lc, ps

        if lc.content_string_looks_like_one_word_

          # "done." => "done frobbing widget."  maybe??

          ev = ps.possibly_wrapped_event
          if ev.verb_lexeme

            Magnetics_::First_Line_Map_via_Evento_Trilean_Idiom::
              That_Is_Lexemic_While_Frobbing.
                map_line_by_of_idiom_that_is_frobbing_item lc, ps
          end
        else
          _map_line_by_doing_colon_thing lc, ps
        end
      end

      def _map_line_by_doing_colon_thing lc, ps

        ev = ps.possibly_wrapped_event
        n_s = ev.inflected_noun
        v_s = ev.verb_lexeme.preterite

        _ = if n_s
          "#{ v_s } #{ n_s }:"  # #c15n-spot-1
        else
          v_s
        end

        lc.mutable_line_parts.prefixed_string = _
        lc.to_string
      end
    end ; end
  end
end
