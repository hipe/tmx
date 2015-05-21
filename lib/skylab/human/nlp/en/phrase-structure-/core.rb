module Skylab::Human

  module NLP::EN

    module Phrase_Structure_  # three laws all the way

      # this node exists *only* to enable the implementation of [#037] `POS`

      # ~ model-ish

      class Sentence_Phrase_Constituency_

        def initialize np, vp
          @noun_phrase = np
          @_verb_phrase = vp
        end

        attr_reader :noun_phrase

        def number
          @noun_phrase.number
        end

        def person
          @noun_phrase.person
        end

        def tense
          @_verb_phrase.tense
        end
      end

      # ~ for irregulars

      class Compound_Lexicon_

        def initialize mod

          mod.send :define_singleton_method,
            :irregular_index,
            IRREGULAR_INDEX_METHOD_

          @_mod = mod
        end

        def touch lemma_string, & edit_p

          @_bx ||= _build_box
          @_bx.touch lemma_string, & edit_p
        end

        def _build_box

          bx = Callback_::Box.new
          st = @_mod.irregular_index.irregular_collection.to_entry_stream

          begin
            lexeme_entry = st.gets
            lexeme_entry or break

            s = lexeme_entry.lemma_x
            s or self.sanity
            s.freeze  # probably not OK here

            bx.add s, lexeme_entry
            redo
          end while nil
          bx
        end
      end

      class Lazy_lexicon_

        # a new experiment, similar to above

        class << self
          alias_method :[], :new
          private :new
        end  # >>

        def initialize mod, const
          @_const = const
          @_mod = mod
        end

        def touch lemma_x, & create_p

          lex = @_mod.const_get @_const, false
          lex.init_lexicon @_mod
          @_mod.replace_lexicon lex
          lex.touch lemma_x, & create_p
        end
      end

      IRREGULAR_INDEX_METHOD_ = -> do
        @___irregular_index ||= Models::Irregular::Index.new self
      end

      # ~ shared production support

      Add_S_ending_ = -> do

        p = -> s do

          ends_in_etc = /(?: ch | sh? )\z/ix  # ick: "matches"
          ends_in_y = /y\z/i

          p = -> s_ do

            case s_
            when ends_in_y

              s_.sub ends_in_y, 'ies'

            when ends_in_etc

              "#{ s_ }es"

            else
              "#{ s_ }s"
            end
          end

          p[ s ]
        end

        -> s do
          p[ s ]
        end
      end.call

      Autoloader_[ Actors = ::Module.new ]
      EN_ = NLP::EN
      Autoloader_[ Models = ::Module.new ]
      Phrase_Structure_ = self

    end
  end
end
