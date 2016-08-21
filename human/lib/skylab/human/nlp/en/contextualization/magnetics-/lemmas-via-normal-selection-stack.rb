module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Lemmas_via_Normal_Selection_Stack < Magnet_  # referenced 2x

      # if wasn't for the second reference, would be a #feature-island

      def execute

        slug_a = @ps_.normal_selection_stack

        @_length = slug_a.length
        if @_length.nonzero?
          @_slug_a = slug_a
        end

        o = Lemmas___.new

        o.verb_subject_string = __subject_string
          # whether trueish or not, it is now known

        o.verb_lemma_string = __verb_lemma_string  # ditto

        o.verb_object_string = __object_string  # ditto

        o
      end

      def __subject_string

        if @ps_.subject_association  # experimental here
          Magnetics_::Subject_Association_String_via_Subject_Association[ @ps_ ]
        else
          __subject_string_classically
        end
      end

      def __subject_string_classically

        if @_length.nonzero?
          s = @_slug_a.fetch 0
          if _has_many_adjectives
            if s
              s = "#{ s } #{ @_slug_a[ 1 .. -3 ].reverse.join SPACE_ }"
            else
              self._COVER_ME
            end
          end
          s
        end
      end

      def __verb_lemma_string
        if 1 < @_length
          @_slug_a.fetch( -1 )
        end
      end

      def __object_string
        if 2 < @_length
          if _has_many_adjectives
            @_slug_a[ -2 ]
          else
            @_slug_a[ 1 .. -2 ].join SPACE_
          end
        end
      end

      def _has_many_adjectives  # (ridiculous)
        5 < @_length
      end

      # ==

      Lemmas___ = ::Struct.new(
        :verb_subject_string,
        :verb_lemma_string,
        :verb_object_string,
      )
    end
  end
end
# #history: broke out of "nestedly"
