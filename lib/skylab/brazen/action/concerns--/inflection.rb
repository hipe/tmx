module Skylab::Brazen

  class Action

    class Concerns__::Inflection

      def initialize upstream, cls

        @_class = cls
        @_up = upstream
      end

      def execute

        @_inflection = Model___.new
        process_polymorphic_stream_passively @_up
        __accept @_inflection
      end

      include Callback_::Actor::Methodic.polymorphic_processing_instance_methods

    private

      def noun=
        _parse :noun
      end

      def verb=
        _parse :verb
      end

      def verb_as_noun=
        _parse :verb_as_noun
      end

      def _parse sym

        x = @_up.gets_one
        __take_one x, sym
        __take_any_others sym
      end

      def __take_one x, sym

        infl = @_inflection

        if x.respond_to? :id2name

          if :with_lemma == x

            infl._set_lemma @_up.gets_one, sym

          else

            infl._set_combination x, sym
          end
        else

          infl._set_lemma x, sym
        end

        NIL_
      end

      def __take_any_others sym

        infl = @_inflection ; st = @_up

        while st.unparsed_exists

          x = st.current_token

          if x.respond_to? :ascii_only?

            infl._set_lemma st.gets_one, sym

          elsif :with_lemma == x

            st.advance_one
            infl._set_lemma st.gets_one, sym

          else
            break
          end
        end

        KEEP_PARSING_
      end

      def __accept _ACTION_INFLECTION_

        @_class.send :define_singleton_method, :custom_action_inflection do
          _ACTION_INFLECTION_
        end

        KEEP_PARSING_
      end

      class Model___

        attr_reader :has_verb_exponent_combination,
          :has_verb_lemma,
          :verb_lemma,

          :has_noun_exponent_combination,
          :has_noun_lemma,
          :noun_lemma,

          :has_verb_as_noun_lemma,
          :verb_as_noun_lemma

        def noun_exponent_combination_symbol
          @__noun__exponent_combination_symbol
        end

        def verb_exponent_combination_symbol
          @__verb__exponent_combination_symbol
        end

        def _set_lemma s, sym

          instance_variable_set :"@has_#{ sym }_lemma", true
          instance_variable_set :"@#{ sym }_lemma", s

          NIL_
        end

        def _set_combination sym, sym_

          instance_variable_set(
            :"@has_#{ sym }_exponent_combination", true )

          instance_variable_set(
            :"@__#{ sym_ }__exponent_combination_symbol", sym )

          NIL_
        end
      end
    end
  end
end
