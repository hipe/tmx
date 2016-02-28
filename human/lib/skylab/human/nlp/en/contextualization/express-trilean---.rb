module Skylab::Human

  class NLP::EN::Contextualization

    class Express_Trilean___

      GIVEN__ = [
        :trilean,
        :verb_lemma,
        :verb_subject,
      ]

      MAKE__ = [
        :initial_phrase_conjunction,
        :inflected_verb,
      ]

      def initialize kns
        @knowns_ = kns
      end

      def classically_but
        o = Classically__[].dup
        @knowns_.when_ GIVEN__, MAKE__, & o.to_proc
        o
      end

      def classically
        @knowns_.when_ GIVEN__, MAKE__, & Classically__[].to_proc
        NIL_
      end

      Classically__ = Lazy_.call do
        o = Classifier___.new
        o.on_failed = Classically_Failed___
        o.on_neutralled = Classically_Neutraled___
        o.on_succeeded = Classically_Succeeded___
        o
      end

      class Classifier___

        attr_writer(
          :on_failed,
          :on_neutralled,
          :on_succeeded,
        )

        def initialize_copy _
          @___to_proc = nil
        end

        def to_proc
          @___to_proc ||= method :_via
        end

        def _via kns
          x = kns.trilean.value_x
          if x
            @on_succeeded[ kns ]
          elsif x.nil?
            @on_neutralled[ kns ]
          else
            @on_failed[ kns ]
          end
        end
      end

      _FAILED = nil

      Classically_Failed___ = -> kns do

        vl = kns.verb_lemma.value_x
        _ = if vl
          "failed to #{ vl }"
        else
          _FAILED ||= "failed".freeze
        end

        kns.initial_phrase_conjunction = NONE_
        kns.inflected_verb = _
        NIL_
      end

      Classically_Neutraled___ = -> kns do

        vl = kns.verb_lemma.value_x

        _ing = if vl
          Home_::NLP::EN::POS.progressive_verb vl
        else
          'processing request'
        end

        _ = kns.verb_subject.value_x
        _inflected_verb = if _
          "was #{ _ing }"
        else
          _ing
        end

        kns.initial_phrase_conjunction = 'while'
        kns.inflected_verb = _inflected_verb
        NIL_
      end

      Classically_Succeeded___ = -> kns do

        vl = kns.verb_lemma.value_x
        _ = if vl
          Home_::NLP::EN::POS.preterite_verb vl
        else
          'succeeded'
        end

        kns.initial_phrase_conjunction = NONE_
        kns.inflected_verb = _
        NIL_
      end
    end
  end
end
# #history: broke out of sibling file