module Skylab::Brazen

  class Model_

    module Inflection_Kernel__  # see [#016]
      class << self

        def for_model nf
          Model_Inflection_Kernel__.new nf
        end

        def for_action nf
          Action_Inflection_Kernel__.new nf
        end
      end

      class Model_Inflection_Kernel__

        def initialize name_function
          @nf = name_function
          @cls = @nf.cls
          @ci = @cls.custom_branch_inflection
        end

        def noun_lexeme
          @noun_lexeme ||= produce_noun_lexeme
        end

      private

        def produce_noun_lexeme
          s = if @ci && @ci.has_noun_lemma
            @ci.noun_lemma
          else
            infer_noun_stem
          end
          s and Lib_::NLP[]::EN::POS::Noun[ s ]
        end

        def infer_noun_stem  # #to-determine-a-noun
          produce_noun_stem_from_node_path 0
        end

        def produce_noun_stem_from_node_path ignore_num
          scn = get_lemma_scan ignore_num
          s_a = scn.to_a
          if s_a.length.nonzero?  # perhaps a top-most verb
            s_a.reverse!  # it was built from deepest to shallowest

            if 1 < s_a.length  # #the-flip
              s = s_a[ 0 ]
              s_a[ 0 ] = s_a[ 1 ]
              s_a[ 1 ] = s
            end
            s_a * SPACE_
          end
        end

        def get_lemma_scan ignore_num
          scn = get_module_scan_upwards
          ignore_num.times do
            scn.gets
          end
          scn.map_by do |mod|
            if mod.respond_to? :custom_branch_inflection
              cbi = mod.custom_branch_inflection
              cbi and noun_s = cbi.noun_lemma
            end
            noun_s or get_clean_noun_stem_from_module mod
          end
        end

        def get_module_scan_upwards
          mod = @cls
          LIB_.stream.new do
            if mod
              x = mod
              mod = mod.name_function.parent
            end
            x
          end
        end

        # ~ cleaning

        def get_clean_noun_stem_from_module cls
          nf = cls.name_function
          s = nf.as_const.to_s
          remove_trailing_underscores s
          remove_interceding_underscores s
          depluralize s
          nf.class.via_const( s ).as_human
        end

        def remove_trailing_underscores s
          s.gsub! TRAILING_UNDERSCORES_RX__, EMPTY_S_ ; s
        end
        TRAILING_UNDERSCORES_RX__ = /_+$/

        def remove_interceding_underscores s
          s.gsub! INTERCEDING_UNDERSCORES_RX__ do
            $1.downcase
          end ; s
        end
        INTERCEDING_UNDERSCORES_RX__ = /_([A-Z])/

        def depluralize s
          s.gsub! TRAILING_LETTER_S_RX__, EMPTY_S_ ; s
        end
        TRAILING_LETTER_S_RX__ = /s\z/

      end

      class Action_Inflection_Kernel__ < Model_Inflection_Kernel__

        def initialize name_function
          @nf = name_function
          @cls = @nf.cls
          @ci = @cls.custom_action_inflection
        end

        def inflected_verb
          verb_lexeme.send verb_exponent_combination_i
        end

        def verb_lexeme
          @verb_lexeme ||= produce_verb_lexeme
        end

        def verb_exponent_combination_i
          @verb_exponent_combination_i ||= prdc_verb_exponent_combination_i
        end

        def inflected_noun
          if noun_lexeme
            noun_lexeme.send noun_exponent_combination_i
          end
        end

        def noun_exponent_combination_i
          @noun_exponent_combination_i ||= prdc_noun_exponent_combination_i
        end

      private

        def produce_verb_lexeme
          _s = if @ci and s = @ci.verb_lemma
            s
          else
            @nf.as_human
          end
          Lib_::NLP[]::EN::POS::Verb[ _s ]
        end

        def prdc_verb_exponent_combination_i
          if @ci && @ci.has_verb_exponent_combination
            @ci.verb_exponent_combination_i
          else
            :lemma  # i.e do not inflect, just use the "dictionary entry" word
          end
        end

        def infer_noun_stem  # #to-determine-a-noun
          s = produce_noun_stem_from_node_path 1
          s or infer_noun_stem_when_node_is_topmost_node
        end

        def infer_noun_stem_when_node_is_topmost_node  # #note-170
          if @ci && @ci.has_verb_lemma
            @nf.as_human
          end
        end

        def prdc_noun_exponent_combination_i
          if @ci && @ci.has_noun_exponent_combination
            @ci.noun_exponent_combination_i
          else
            :indefinite_singular  # "add a couch db datastore"
          end
        end
      end
    end
  end
end
