module Skylab::Human

  module NLP::EN::Phrase_Structure_

    Models::Lexicon = ::Module.new

    class Models::Lexicon::Prototype

      def initialize h

        @_h = h
        @_is_initialized = {}
      end

      def init_lexicon mod
        @_syntactic_category_module = mod
        NIL_
      end

      def touch lemma_x

        if @_h.key? lemma_x

          if @_is_initialized[ lemma_x ]

            @_h.fetch lemma_x

          else
            __touch_via_initialize_known_lexeme lemma_x
          end
        else

          lexeme = yield

          # $stderr.puts "ADDING REULGAR NOUN: \"#{ lexeme.as_lemma_string_ }\""

          @_is_initialized[ lemma_x ] = true
          @_h[ lemma_x ] = lexeme
          lexeme
        end
      end

      def __touch_via_initialize_known_lexeme lemma_x

        @_is_initialized[ lemma_x ] = true

        _lxm_cls = @_syntactic_category_module.lexeme_class

        _row = @_h.fetch lemma_x

        lexeme = _lxm_cls.via_lemma_and_iambic lemma_x, _row

        @_h[ lemma_x ] = lexeme

        lexeme
      end
    end
  end
end
