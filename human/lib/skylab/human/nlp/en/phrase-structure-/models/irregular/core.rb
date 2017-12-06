module Skylab::Human

  module NLP::EN::Phrase_Structure_

    module Models::Irregular

      class Index

        def initialize mod

          cat_ivar_h = ::Hash.new do | h, k |
            h[ k ] = :"@#{ k }"
          end

          exp_ivar_h = {}

          mod::UNIQUE_EXPONENTS.each do | ( exp_sym, cat_sym ) |

            exp_ivar_h[ exp_sym ] = cat_ivar_h[ cat_sym ]
          end

          cat_ivar_h.default_proc = nil

          @my_category_ivar_h = cat_ivar_h.freeze

          @my_exponent_ivar_h = exp_ivar_h.freeze

          @_parent_exponent_symbols =
            ( mod::GRAMMATICAL_CATEGORIES - cat_ivar_h.keys ).freeze

          @module = mod
        end

        attr_reader :module, :my_category_ivar_h, :my_exponent_ivar_h

        def grammatical_categories
          @module::GRAMMATICAL_CATEGORIES
        end

        # ~ concerns specifically for irregulars

        def irregular_collection
          @___ic ||= Collection___.new self
        end

        def form_class

          if ! @module.const_defined? :Form
            __make_form_class
          end
          @module.const_get :Form, false
        end

        def __make_form_class

          a = @_parent_exponent_symbols
          ivar_h = @my_exponent_ivar_h.dup

          if a.length.nonzero?
            h = ::Hash.new [ a.map { |i| [ i, true ] } ]
            _par = @module::PARENT.call
            _par::UNIQUE_EXPONENTS.each_pair do | ( exp_sym, cat_sym ) |
              h[ cat_sym ] or next
              ivar_h[ exp_sym ] = :"@#{ cat_sym }"
            end
          end

          cls = @module.const_set :Form, ::Class.new( Form___ )
          cls.const_set :IVARS__, ivar_h
          cls.send :attr_reader, * @module::GRAMMATICAL_CATEGORIES

          NIL_
        end
      end

      class Collection___

        def initialize index

          @_converted_h = {}
          @_form_class = index.form_class
          @_module = index.module
          @_raw_h = index.module::LEXICON_OF_IRREGULARS[]
        end

        def to_entry_stream

          d = -1 ; ks = @_raw_h.keys ; last = ks.length - 1

          Common_.stream do
            if d < last
              entry_for ks.fetch( d += 1 )
            end
          end
        end

        def entry_for lemma_x

          @_converted_h.fetch lemma_x do

            x = Lexeme_Entry___.new(
              lemma_x,
              @_raw_h.fetch( lemma_x ),
              @_form_class,
              @_module )

            @_converted_h[ lemma_x ] = x
            x
          end
        end
      end

      class Lexeme_Entry___

        def initialize lemma_x, h, form_class, mod

          @lemma_x = lemma_x

          d = -1

          x = ::Array.new h.length

          h.each_pair do | a, lemma_s |

            x[ d += 1 ] = form_class.new a, lemma_s
          end

          @form_array = x.freeze
          @_module = mod
        end

        def inflect_words_into_against_sentence_phrase y, sp

          _and_a = __to_grammatical_category_state_around_ sp

          inflect_words_into_against_exponent_state_ y, _and_a
        end

        def __to_grammatical_category_state_around_ phrase

          and_a = []
          @_module::GRAMMATICAL_CATEGORIES.each do | cat_sym |
            x = phrase.send cat_sym
            x or next
            and_a.push [ cat_sym, x ]
          end
          if and_a.length.nonzero?
            and_a
          end
        end

        def inflect_words_into_against_exponent_state_ y, and_a

          _st = Stream_[ @form_array ]

          Irregular_::InflectedWords_via_ExponentState___[ y, and_a, _st ]
        end

        def as_lemma_symbol_if_possible_

          # (name leaves room for irregular lexemes w/o lemma (The Pronoun))

          @lemma_x.intern  # no need to memoize symbols, right?
        end

        attr_reader(
          :lemma_x,
        )

        def is_regular  # ..
          false
        end
      end

      class Form___

        def initialize a, lemma_s

          @surface_string = lemma_s.freeze  # assume etc

          ivar_h = self.class::IVARS__

          a.each do | sym |
            instance_variable_set ivar_h.fetch( sym ), sym
          end
        end

        attr_reader :surface_string
      end

      Irregular_ = self
    end
  end
end
