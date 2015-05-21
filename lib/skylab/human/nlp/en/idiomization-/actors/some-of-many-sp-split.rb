module Skylab::Human

  module NLP::EN::Idiomization_

    Actors::Some_of_many_sp_split = -> sp, si do  # assume two or more

      # before: "the 2 found items have no content after them"

      # ->

        _POS = EN_::POS

        if si.quad_count.is_two

          np_ = _POS::Noun.phrase_via_string 'neither of it'

        else

          np_ = _POS::Noun.phrase_via_string 'none of it'

        end

        # as long as the above first lexems are not in our lexicon
        # we have to assign some exponents manually ..

        np_ << :singular << :third << :_do_not_use_article_

        _ = np_.prepositional_phrases.fetch_last_item.noun_phrase
        _ << :plural  # we grabbed the lemma above

        _np = sp.replace_noun_phrase np_

        # _np: "the 2 found items"
        # sp: "neither of them have no content after them"

        sp.verb_phrase.object_noun_phrase << :_do_not_use_article_  # see above

        # make "of the 2 found items"

        _pp = _POS::Preposition.phrase_via _np, 'of'

        sp.prepend_early_modifier_clause _pp

        NIL_

      # after: "of the 2 found items, neither of them have content after them"

        # <-

    end
  end
end
