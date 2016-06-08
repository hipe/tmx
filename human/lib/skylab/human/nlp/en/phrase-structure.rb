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

        def express_words_into_under y, expag
          y << @_s
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

          p = -> y, ph, s_a_ do

            s_a_.each do | s |
              y << s
            end
            y
          end

          @inflect_words_into_against_noun_phrase = p

          @inflect_words_into_against_sentence_phrase = p

        end

        def inflect_words_into_against_noun_phrase_under y, np, expag
          @inflect_words_into_against_noun_phrase_under[ y, np, expag, @_s_a ]
        end

        attr_writer :inflect_words_into_against_noun_phrase

        attr_writer :inflect_words_into_against_noun_phrase_under

        attr_writer :inflect_words_into_against_sentence_phrase
      end

      class Noun_inflectee_via_word_array < Via_w_ary__

        def inflect_words_into_against_noun_phrase y, np
          @inflect_words_into_against_noun_phrase[ y, np, @_s_a ]
        end
      end

      class Sentence_inflectee_via_word_array < Via_w_ary__

        def inflect_words_into_against_sentence_phrase y, sp
          @inflect_words_into_against_sentence_phrase[ y, sp, @_s_a ]
        end
      end

      class Via_ph_ary__

        class << self

          def via_phrases x, * a

            list = new x
            m = _append_method_
            a.each do | x_ |
              list.send m, x_
            end
            list
          end

          alias_method :[], :new
          private :new
        end  # >>

        def initialize x
          @_ph_a = [ x ]
        end

        def express_string_into_under y, expag  # :+#experimenal here

          _y_ = express_words_into_under [], expag
          y << Home_::Phrase_Assembly::Sentence_string_head_via_words[ _y_ ]
        end

        def express_words_into_under y, expag

          @_ph_a.each do | ph |
            ph.express_words_into_under y, expag
          end
          y
        end

        def to_stream_of_pronouns

          Common_::Stream.via_nonsparse_array( @_ph_a ).expand_by do | ph |
            ph.to_stream_of_pronouns
          end
        end

        def replace_only_item x_

          x =  @_ph_a.fetch @_ph_a.length << 1 - 2
          @_ph_a[ 0 ] = x_
          x
        end

        def replace_first_item x_

          x = @_ph_a.fetch 0
          @_ph_a[ 0 ] = x_
          x
        end

        def fetch_last_item
          @_ph_a.fetch( -1 )
        end
      end

      class Mutable_phrase_list_as_noun_inflectee < Via_ph_ary__

        def inflect_words_into_against_noun_phrase y, np
          @_ph_a.each do | ph |
            ph.inflect_words_into_against_noun_phrase y, np
          end
          y
        end

        def inflect_words_into_against_noun_phrase_under y, np, expag
          @_ph_a.each do | ph |
            ph.inflect_words_into_against_noun_phrase_under y, np, expag
          end
          y
        end

        def prepend_noun_inflectee x
          @_ph_a.unshift x
          NIL_
        end

        def append_noun_inflectee x
          @_ph_a.push x
          NIL_
        end

        def self._append_method_
          :append_noun_inflectee
        end
      end

      class Mutable_phrase_list_as_sentence_inflectee < Via_ph_ary__

        def inflect_words_into_against_sentence_phrase y, x
          @_ph_a.each do | ph |
            ph.inflect_words_into_against_sentence_phrase y, x
          end
          y
        end

        def prepend_sentence_inflectee x
          @_ph_a.unshift x
          NIL_
        end

        def append_sentence_inflectee x
          @_ph_a.push x
          NIL_
        end

        def self._append_method_
          :append_sentence_inflectee
        end
      end
    end
  end
end
