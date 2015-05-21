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

      class Via_w_ary__

        class << self
          alias_method :[], :new
        end  # >>

        def initialize s_a
          @_s_a = s_a
        end

        def _go y
          @_s_a.each do | s |
            y << s
          end
          y
        end
      end

      class Noun_inflectee_via_word_array < Via_w_ary__

        def inflect_words_into_against_noun_phrase y, _
          _go y
        end
      end

      class Sentence_inflectee_via_word_array < Via_w_ary__

        def inflect_words_into_against_sentence_phrase y, _
          _go y
        end
      end

      class Via_p_ary__

        class << self
          alias_method :[], :new
        end  # >>

        def initialize x
          @_p_a = [ x ]
        end

        def to_stream_of_pronouns

          Callback_::Stream.via_nonsparse_array( @_p_a ).expand_by do | ph |
            ph.to_stream_of_pronouns
          end
        end

        def replace_only_item x_

          x =  @_p_a.fetch @_p_a.length << 1 - 2
          @_p_a[ 0 ] = x_
          x
        end

        def replace_first_item x_

          x = @_p_a.fetch 0
          @_p_a[ 0 ] = x_
          x
        end

        def fetch_last_item
          @_p_a.fetch( -1 )
        end
      end

      class Mutable_phrase_list_as_noun_inflectee < Via_p_ary__

        def inflect_words_into_against_noun_phrase y, x
          @_p_a.each do | ph |
            ph.inflect_words_into_against_noun_phrase y, x
          end
          y
        end

        def prepend_noun_inflectee x
          @_p_a.unshift x
          NIL_
        end

        def append_noun_inflectee x
          @_p_a.push x
          NIL_
        end
      end

      class Mutable_phrase_list_as_sentence_inflectee < Via_p_ary__

        def inflect_words_into_against_sentence_phrase y, x
          @_p_a.each do | ph |
            ph.inflect_words_into_against_sentence_phrase y, x
          end
          y
        end

        def prepend_sentence_inflectee x
          @_p_a.unshift x
          NIL_
        end

        def append_sentence_inflectee x
          @_p_a.push x
          NIL_
        end
      end
    end
  end
end
