module Skylab::Brazen

  class Concerns_::Name

    Sessions_ = ::Module.new

    class Sessions_::Deep_Action_Isomorphicism_for_EN  # compare [#hu-043]

      # :+[#sl-134] this is a feature island - this is covered ONLY by a
      # spec but  it is not currently used anywhere in production. however
      # we retain it for the tme being for now for possible

      def initialize slug_a
        @len = slug_a.length
        @slug_a = slug_a
      end

      def to_string_array_for_succeeded
        y = []
        if @len.nonzero?
          y << 'while'
          express_into_yielder_any_subject_noun_phrase y
          _did = express_into_yielder_any_past_progressive_verb y
          _did or y << 'was processing request'
          express_into_yielder_any_adjectives y
          express_into_yielder_any_object_noun y
        end
        y
      end

      def to_string_array_for_failed
        y = []
        if @len.nonzero?
          express_into_yielder_any_subject_noun_phrase y
          _did = express_into_yielder_any_prefixed_verb y, 'failed to'
          _did or y << 'failed'
          express_into_yielder_any_adjectives y
          express_into_yielder_any_object_noun y
        end
        y
      end

      def express_into_yielder_any_subject_noun_phrase y
        if @len.nonzero?
          y << @slug_a.fetch( 0 )
          if _has_many_adjectives
            y.concat @slug_a[ 1 .. -3 ].reverse
          end
          DONE_
        end
      end

      def express_into_yielder_any_past_progressive_verb y
        v_o = _any_curried_verb
        if v_o
          y << "was #{ v_o.lexeme.progressive }"
          DONE_
        end
      end

      def express_into_yielder_any_prefixed_verb y, prefix_s
        v_o = _any_curried_verb
        if v_o
          y << "#{ prefix_s } #{ v_o.lemma }"
          DONE_
        end
      end

      def express_into_yielder_any_adjectives y
        if 3 < @len and ! _has_many_adjectives
          y.concat @slug_a[ 1 .. -3 ]
          DONE_
        end
      end

      def express_into_yielder_any_object_noun y
        n_o = _any_curried_object_noun
        if n_o
          y << n_o.to_string
          DONE_
        end
      end

      def _any_curried_verb

        if 1 < @len

          s = @slug_a.fetch( -1 )
          s.respond_to?( :ascii_only? ) or self._DO_ME

          Home_.lib_.human::NLP::EN::POS::Verb[ s ]
        end
      end

      def _has_many_adjectives
        5 < @len
      end

      def _any_curried_object_noun

        if 2 < @len

          s = @slug_a.fetch( -2 )
          s.respond_to?( :ascii_only? ) or raise self._DO_ME
          Home_.lib_.human::NLP::EN::POS::Noun[ s ] << :_do_not_use_article_
        end
      end
    end
  end
end