module Skylab::Brazen

  module Nodesque::Name::Common_Inflectors  # [#016] describes adj-noun-verb pattern

    # although there are dedicated cateogry nodes for the below two,
    # they are in this same file because they are algorithmically related.

    class Inflector_for_Model

      def initialize name_function

        cls = name_function.class_

        @_custom_action_inflection = if cls.respond_to? :custom_branch_inflection
          cls.custom_branch_inflection
        end

        @_class = cls

        @_name_function = name_function
      end

      def noun_lexeme

        @___noun_lexeme ||= __produce_noun_lexeme
      end

      def __produce_noun_lexeme

        s = if @_custom_action_inflection && @_custom_action_inflection.has_noun_lemma
          @_custom_action_inflection.noun_lemma
        else
          __infer_noun_stem
        end
        s and LIB_.human::NLP::EN::POS::Noun[ s ]
      end

      def __infer_noun_stem  # #to-determine-a-noun

        produce_noun_stem_from_node_path 0
      end

      def produce_noun_stem_from_node_path ignore_num

        scn = get_lemma_scan ignore_num

        s_a = scn.to_a

        if s_a.length.nonzero?  # perhaps a top-most verb

          s_a.reverse!  # it was built from deepest to shallowest

          # (if it's exactly two elements, leave it as is)

          if 2 < s_a.length  # #the-flip

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

        mod = @_class
        etc = nil

        p = -> do
          if mod
            if mod.respond_to? :name_function
              x = mod
              mod = mod.name_function.parent
              x
            else
              etc[]
            end
          end
        end

        etc = -> do
          x_a = Home_.lib_.basic::Module.chain_via_module mod
          stru = x_a[ -3 ]
          x = mod
          mod = if stru
            stru.value_x
          end
          x
        end

        Callback_.stream do
          p[]
        end
      end

      # ~ cleaning

      def get_clean_noun_stem_from_module cls

        nf = if cls.respond_to? :name_function
          cls.name_function
        else
          Callback_::Name.via_module cls
        end

        s = nf.as_const.to_s

        __mutate_by_removing_trailing_underscores s
        __mutate_by_removing_interceding_underscores s
        __mutate_by_depluralizing s

        nf.class.via_const( s ).as_human
      end

      def __mutate_by_removing_trailing_underscores s

        s.gsub! TRAILING_UNDERSCORES_RX___, EMPTY_S_ ; s
      end

      TRAILING_UNDERSCORES_RX___ = /_+$/

      def __mutate_by_removing_interceding_underscores s

        s.gsub! INTERCEDING_UNDERSCORES_RX___ do
          $1.downcase
        end
        NIL_
      end

      INTERCEDING_UNDERSCORES_RX___ = /_([A-Z])/

      def __mutate_by_depluralizing s
        s.gsub! TRAILING_LETTER_S_RX___, EMPTY_S_
        NIL_
      end

      TRAILING_LETTER_S_RX___ = /s\z/

    end

    class Inflector_for_Action < Inflector_for_Model

      def initialize name_function

        @_name_function = name_function

        @_class = @_name_function.class_

        @_custom_action_inflection = @_class.custom_action_inflection
      end

      def inflected_verb
        verb_lexeme.send verb_exponent_combination_symbol
      end

      def verb_lexeme

        @___vl ||= __produce_verb_lexeme
      end

      def verb_as_noun_lexeme

        @___did_resolve_verb_as_noun_lexeme ||= __rslv_VAN_lexeme
        @__any_verb_as_noun_lexeme
      end

      def verb_exponent_combination_symbol

        @___vec_i ||= __some_verb_exponent_combination_symbol
      end

      def inflected_noun

        o = noun_lexeme
        if o
          o.send noun_exponent_combination_symbol
        end
      end

      def noun_exponent_combination_symbol

        @___nec_i ||= __some_noun_exponent_combination_symbol
      end

      def __produce_verb_lexeme

        ci = @_custom_action_inflection

        if ci
          s = ci.verb_lemma
        end

        s ||= @_name_function.as_human

        LIB_.human::NLP::EN::POS::Verb[ s ]
      end

      def __rslv_VAN_lexeme

        ci = @_custom_action_inflection

        if ci
          if ci.has_verb_as_noun_lemma
            x = LIB_.human::NLP::EN::POS::Noun[ ci.verb_as_noun_lemma ]
          end
        end

        @__any_verb_as_noun_lexeme = x
        ACHIEVED_
      end

      def __some_verb_exponent_combination_symbol

        ci = @_custom_action_inflection

        if ci
          if ci.has_verb_exponent_combination
            _sym = ci.verb_exponent_combination_symbol
          end
        end

        _sym || :lemma  # i.e do not inflect, just use the "dictionary entry" word
      end

      def __infer_noun_stem  # #to-determine-a-noun

        s = produce_noun_stem_from_node_path 1
        s or __infer_noun_stem_when_node_is_topmost_node
      end

      def __infer_noun_stem_when_node_is_topmost_node  # #note-170

        ci = @_custom_action_inflection

        if ci && ci.has_verb_lemma
          @_name_function.as_human
        end
      end

      def __some_noun_exponent_combination_symbol

        ci = @_custom_action_inflection

        if ci
          if ci.has_noun_exponent_combination
            _sym = ci.noun_exponent_combination_symbol
          end
        end

        _sym || :indefinite_singular

        # "add a couch db collection"
      end
    end
  end
end
