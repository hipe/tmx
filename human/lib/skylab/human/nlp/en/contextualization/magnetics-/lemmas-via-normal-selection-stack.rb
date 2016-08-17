module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Lemmas_via_Selection_Stack  # referenced 2x

      # if wasn't for the second reference, would be a #feature-island

      class << self

        def via_magnetic_parameter_store ps
          new( ps ).execute
        end

        private :new
      end  # >>

      def initialize ps
        @_ps = ps
      end

      def execute

        slug_a = __selection_stack_as_moniker_array

        @_length = slug_a.length
        if @_length.nonzero?
          @_slug_a = slug_a
        end

        o = Lemmas___.new

        _vs = __subject_noun_phrase
        o.verb_subject = _vs  # whether trueish or not, it is now known

        _vl = __verb_lemma
        o.verb_lemma = _vl  # ditto

        _on = __object_noun_phrase
        o.verb_object = _on  # ditto

        o
      end

      def __subject_noun_phrase

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

      def __verb_lemma
        if 1 < @_length
          @_slug_a.fetch( -1 )
        end
      end

      def __object_noun_phrase
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

      # --

      _Express_selection_stack_item = -> x do
        nf = x.name  # :[#048]. allows root to have a name
        if nf
          nm nf
        end
      end

      define_method :__selection_stack_as_moniker_array do

        ps = @_ps

        if ! ps.to_say_selection_stack_item
          ps.to_say_selection_stack_item = _Express_selection_stack_item
        end

        _s_a = Magnetics_::String_Array_via_Procs_and_Selection_Stack[ ps ]

        _s_a  # #todo
      end

      # ==

      Lemmas___ = ::Struct.new(
        :verb_subject,
        :verb_lemma,
        :verb_object,
      )

    end
  end
end
# #history: broke out of "nestedly"
