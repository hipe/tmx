module Skylab::Human

  NLP::EN.const_get :Phrase_Structure_, false

  module NLP::EN::Phrase_Structure_

    module NLP::EN::Phrase_Structure

      # an API-public collection of experiments etc..

      class << self
        def noun_inflectee & p
          Noun_inflectee_via_proc___.call( & p )
        end

        def sentence_inflectee & p
          Sentence_inflectee_via_proc___.call( & p )
        end
      end  # >>

      class Via_proc__ < ::Proc

        class << self
          alias_method :call, :new
        end  # >>
      end

      class Noun_inflectee_via_proc___ < Via_proc__

        alias_method :inflect_words_into_against_noun_phrase, :call
      end

      class Sentence_inflectee_via_proc___ < Via_proc__

        alias_method :inflect_words_into_against_sentence_phrase, :call
      end

      class Via_string__

        class << self
          alias_method :[], :new
        end  # >>

        def initialize s
          s or self._SANITY
          @_s = s
        end
      end

      class Noun_inflectee_via_string < Via_string__

        def inflect_words_into_against_noun_phrase y, _
          y << @_s
        end
      end

      class Sentence_inflectee_via_string < Via_string__

        def inflect_words_into_against_sentence_phrase y, _
          y << @_s
        end
      end
    end
  end
end
