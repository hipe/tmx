def _lets_get_slizzy(articles_generator):

    def main():
        reduce_the_list_of_articles()
        for article in self.articles:
            maybe_MUTATE_article(article)

    def maybe_MUTATE_article(article):
        tup = time_bucket_expressers_for_article(article)
        if not tup:
            # (leaving it as-is for now but in the future we might do more)
            return

        """
        HERE IS THE MONEY:

        These are the attributes (set on `article` objects) we are limiting
        ourselves to (which is the ones already used by the "simple"
        template that ships as the default w/ vendor):

        - `date`: a datetime object of when "published"
        - `locale_date`: a string expression of the above
        - `modified`: (any) datetime object of
        - `locale_modified`: same

        We didn't quite realize it when we started the feature … 19 days ago
        that what we are doing is releasing a supercharged variant of this
        existing "feature" (which on its own is just an interplay between
        two fields in frontmatter and these four variables in templates).

        At first we thought our target surface expression was just essentially
        one continuous paragraph of words; but:

        Our target behavior is close enough to this existing behavior
        (as it appears in surface expression) that we have spent today
        retrofitting the new work to work in the existing templates without
        them having to know about it which is GREAT
        """

        # If there were any buckets, then there is at least one (heh). But
        # keep in mind it's possible that "CREATE" and "EDIT" are munged in
        # that frst bucket. Keep in mind too "CREATE" isn't exactly one
        # discrete event when it comes to notecard-based documents.

        first_bucket, *subsequent_buckets = tup

        article.date = first_bucket.earliest_datetime
        article.locale_date = first_bucket.to_line_no_end()

        # (many documents have only the first document-commit)
        if not subsequent_buckets:
            return

        def lines():
            for time_bucket_expressers in subsequent_buckets:
                yield time_bucket_expressers.to_line_with_end()

        article.locale_modified = ''.join(lines())

        article.modified = subsequent_buckets[-1].latest_datetime
        # (since we have to pick just one modified date, we used the last
        # datetime of the last bucket, which is what *we* expect the *user*
        # expects to be implied of a field called "modified")

    def time_bucket_expressers_for_article(article):
        itr = document_commits_via_title(article.title)
        if not itr:
            return
        doc_ci = next(itr)
        if 'docu_type_common' == doc_ci.document_type:
            use = business_item_for_common
        else:
            assert 'docu_type_rigged' == doc_ci.document_type
            use = business_item_for_rigged

        def business_items():
            yield use(doc_ci)
            for dci in itr:
                yield use(dci)

        business_items = business_items()
        return tuple(time_bucket_expressers_via(business_items))

    self = main  # #watch-the-word-burn
    conf = articles_generator.settings

    coll_path = conf['PHO_COLLECTION_PATH']  # ..
    from pho.document_history_.toolkit import \
        statistitican_via_collection_path as func
    stater = func(coll_path)
    document_commits_via_title = stater.document_commits_via_title

    def time_bucket_expressers_via(business_items):
        return TBEs_via_BIs(business_items, lexicon, datetime_now=datetime_now)

    lexicon = _build_lexicon()
    from datetime import datetime as mod
    datetime_now = mod.now()
    from ._words_via_frames import \
        time_bucket_expressers_via_business_items_ as TBEs_via_BIs

    # Business item via

    def build(mean, std):
        def business_item_via(doc_ci):

            # The deviation of each number is its distance from the mean
            dt, verb, rec, _ = doc_ci

            amount_of_change = (
                rec.number_of_lines_inserted + rec.number_of_lines_deleted)

            devi = abs(float(amount_of_change) - mean)
            size = adjective_via_deviation(devi)

            if 'create' == verb:
                verb_lexeme_key = 'document_creation', None
            else:
                assert 'edit' == verb
                verb_lexeme_key = 'document_edit', size

            return business_item(dt, verb_lexeme_key)

        def adjective_via_deviation(devi):
            if devi < std:
                return 'small'
            if devi < two_std:
                return 'medium'
            return 'large'

        two_std = 2.0 * std
        return business_item_via

    mean_for_common, std_for_common = stater.mean, stater.std
    mean_for_rigged, std_for_rigged = \
        stater.mean_for_rigged, stater.std_for_rigged

    business_item_for_rigged = build(mean_for_rigged, std_for_rigged)
    business_item_for_common = build(mean_for_common, std_for_common)

    from collections import namedtuple as _nt
    business_item = _nt('_BusinessItem', ('datetime', 'verb_lexeme_key'))

    # Redundantly

    def reduce_the_list_of_articles():
        """Annoyingly do this work redundantly with the main place that

        does it because we are stuck far upstream in the pipeline.
        We want to cull out the other work early because it's expensive.
        """

        self.articles = articles_generator.articles
        these = conf.get('WRITE_SELECTED')
        if not these:
            return

        this, = these  # ..
        from os.path import basename
        needle = basename(this)
        art = next(art for art in self.articles if needle == art.url)  # ..
        self.articles = (art,)
    main()


def _build_lexicon():
    class Lexicon:
        def words_via_frame_ish(_, context_stack, counts):
            pp_words = pp_via_cstack(context_stack)
            pp_words = * pp_words[:-1], ''.join((pp_words[-1], '.'))
            words_es = words_es_via_counts(counts)
            my_words = list(words_of_oxford_join(words_es, 'and'))
            my_words[0] = my_words[0].title()
            return *my_words, *pp_words

    def words_es_via_counts(counts):
        for (verb_lex_key, size), count in counts:
            if 'document_creation' == verb_lex_key:
                assert 1 == count
                yield ('Created',)
            else:
                assert 'document_edit' == verb_lex_key
                words = []
                if 1 != count:
                    words.append(str(count))
                if 'medium' != size:
                    words.append(size)
                if 1 == count:
                    words.append('edit')
                else:
                    words.append('edits')
                yield words

    from ._words_via_frames import \
        words_of_oxford_join_ as words_of_oxford_join

    from text_lib.magnetics.words_via_time import \
        prepositional_phrase_words_via_context_stack as pp_via_cstack

    return Lexicon()


def register():
    from pelican import signals
    signals.article_generator_finalized.connect(_lets_get_slizzy)

# #history-B.4 spike initial
# #born
