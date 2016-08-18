module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::First_Line_Map_via_Evento_Trilean_Idiom::That_Is_Lexemic_While_Frobbing ; class << self

      def via_magnetic_parameter_store ps

        -> line do
          _lc = Magnetics_::Line_Contextualization_via_Line[ line ]
          __map_line _lc, ps
        end
      end

      alias_method :[], :via_magnetic_parameter_store

      def __map_line lc, ps

        ev = ps.possibly_wrapped_event

        _n_s = ev.inflected_noun

        _one = lc.content_string_looks_like_one_word_

        _pa = if _one or ( _n_s and _n_s.include? SPACE_ )

          # ! "while a workspace opening" [br]

          map_line_by_of_idiom_that_is_frobbing_item lc, ps

        else

          # (WAS: "while fish eating.." [hu])

          map_line_by_of_idiom_that_is_frobbing_item lc, ps
          # __NOT_USED_but_keep_around__map_line_by_of_idiom_that_is_item_frobbing lc, ps
        end
      end

      def map_line_by_of_idiom_that_is_frobbing_item lc, ps

        _same lc, ps do |pa, verb, noun|
          pa.add_string verb
          pa.add_any_string noun
        end
      end

      def __NOT_USED_but_keep_around__map_line_by_of_idiom_that_is_item_frobbing lc, ps

        _same lc, ps do |pa, verb, noun|
          pa.add_any_string noun
          pa.add_string verb
        end
      end

      def _same lc, ps

        pa = Home_::PhraseAssembly.begin_phrase_builder
        pa.add_lazy_space

        lexz = ps.possibly_wrapped_event
        _verb = lexz.verb_lexeme.progressive
        _noun = lexz.inflected_noun

        yield pa, _verb, _noun

        gerund_phrase = pa.flush_to_string

        _mlp = lc.mutable_line_parts

        eek_mutable = _mlp.normalized_original_content_string

        if lc.content_string_looks_like_one_word_

          eek_mutable.concat gerund_phrase
        else
          eek_mutable[ 0, 0 ] = "while#{ gerund_phrase }, "
        end

        lc.to_string
      end
    end ; end
  end
end
