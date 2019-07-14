#!/usr/bin/env python3 -W error::Warning::0

"""
first, we'll develop the question of whether there's a practical discernable
difference between tags and features. then we'll imagine some possible metrics,
then finally we'll formulate a report that could populate those metrics.

  - one thing we've observed empirically is that some (many? most? all?)
    alternatives will associate with the "same" phenomenon as both a
    feature *and* a tag.

  - the idea is that if it can be show that tags are almost always used
    interchangeably with features, then it's a false dichotomy (or poorly
    inforced distinction or bad wabi-sabi in interface or what have you), and
    it follows that the dichotomy should be ignored (or the system improved).
    in other words, the distinction between tag vs feature might be mostly
    useless.

  - parenthetically, it might be an interesting derived characteristic to
    consider about each alternative: how much it respects the boundary
    between tags and features as compared to other alternatives. (but the
    question should be asked if an alternative deserves to be "punished"
    in this manner if the system itself suffers from poor design (e.g
    validation).

  - but in order to "prove" that this tendency is prevalent (or detect it
    in the first place for any given alternative), we need a way to measure
    its occurrence. the remainder of this section is concerned with offering
    such a way.

  - a crude metric for how much a given alternative does this could be thru
    what we'll call the "uselessness (of dichotomy)" which we define thus:

  - we'll define uselessness as a straighforward function with these inputs:

      A) the number of phenomena that are in the features set only
      B) the number of phenomena that are in the tags set only
      C) the number of phenomena that are in both

  - if the number is 0 for all of these, "usefulness of the dichotomy" is
    a meaningless question in regards to this alternative, because it does
    not associate with any phenomena at all. don't count this alternative
    at all in the report.

  - we'll extend this idea a bit further: if the *overall* number of feature
    associations *and/or* tag associations is zero, we'll also say don't
    count this alternative in the report. we only want alternatives that have
    both feature and tag associations to measure the frequency of what we're
    measuring. (to get the overall number for the thing, you have to add the
    "both" number and the other number.)

  - ok, now we have an alternative with some feature association and some
    tag associations. this is an alternative that will count in our report.
    the uselessness rating is the number that are both divided by the average
    of the number of features and the number of tags.

        ( number in both ) /
        ( ( overall number of features + overall number of tags ) / 2 )

    so for example:
      - if you have 5 features and 5 tags and 5 are in both, it's 100% useless
        (the dichotomy, that is).

      - if you have 1 million features and 1 tag and 0 are in both, 0% useless
        (i.e the dichotomy is useful).

      - if you have 4 features and 6 tags and 4 are in both, 80% useless

      - if you have 6 features and 6 tags and 4 are in both, 66% useless

    again, this is just a crude metric to get an idea what we're dealing with.


so, once we look at the uselessnes rating for each alternative SOMEHOW,
we can perhaps devise:

  A) is there a trend broadly of uselessness? like are more than 50% of
     the alternatives more than 50% useless in their dichotomies?
  B) is the distribution of uselessness pronounced? like is the S-curve
     of the distribution more a straight line? or is it more that there's
     a few outliers but generally the rating is low? a few outliner but
     generaly the rating is high?
"""


from fractions import Fraction as _Fraction


class Report:

    def __init__(self, dispatcher, modality, listener):
        assert('CLI' == modality)
        dispatcher.receive_subscription_to_tap_each_alternative(
                self.__put_this_alternative_in_a_bucket,
                self.__when_that_stuff_is_finished,
                )
        self._skipped_because_didnt_have_both = []
        self._skipped_because_no_assocs_at_all = []
        self._sort_me = []

    def __put_this_alternative_in_a_bucket(self, three, alternative):
        normal_features_only, both, normal_tags_only = three
        num_features_only = len(normal_features_only)
        num_tags_only = len(normal_tags_only)
        num_both = len(both)
        num_features_overall = num_features_only + num_both
        num_tags_overall = num_tags_only + num_both

        count_this = False
        if num_features_overall is 0:
            if num_tags_overall is 0:
                self._skipped_because_no_assocs_at_all.append(alternative)
            else:
                self._skipped_because_didnt_have_both.append(alternative)
        elif num_tags_overall is 0:
            self._skipped_because_didnt_have_both.append(alternative)
        else:
            count_this = True

        if count_this:
            numerator = _Fraction(num_both)
            denominator = _Fraction(num_features_overall + num_tags_overall, 2)
            _wat = numerator / denominator
            self.__PUT_IT_IN_A_BUCKET(_wat, three, alternative)

    def __PUT_IT_IN_A_BUCKET(self, rating, three, alternative):
        # #[#008.H]: come back when you understand data science better
        self._sort_me.append((rating, three, alternative))

    def __when_that_stuff_is_finished(self):
        yield 'THE USELESSNESS OF THE DICHOTOMY:'
        bucket = {}
        for rating, three, alternative in self._sort_me:
            if rating in bucket:
                ls = bucket[rating]
            else:
                ls = []
                bucket[rating] = ls
            ls.append((alternative, three))
        del(self._sort_me)

        percent = _percent
        fellow = _fellow
        join = _join

        _ratings_sorted = sorted(bucket.keys(), reverse=True)

        for rating in _ratings_sorted:
            ls = bucket[rating]
            if 1 == len(ls):
                yield f'  {percent(rating)}: {fellow(*ls[0])}'
            else:
                yield f'  {percent(rating)}:'
                for alternative, three in ls:
                    yield f'    {fellow(alternative, three)}'

        _ = _mapsort_alternatives(self._skipped_because_didnt_have_both)
        if len(_):
            yield f"  (skipped because didn't have both: {join(_)})"

        _ = _mapsort_alternatives(self._skipped_because_no_assocs_at_all)
        if len(_):
            yield f"  (skipped because no assocs at all: {join(_)})"


# -- formatters just for above

def _mapsort_alternatives(o_a):
    _ = [x.basename for x in o_a]
    return sorted(_)


def _percent(rating):
    return '%6.2f%%' % (rating * 100)


def _fellow(alternative, three):
    as_feature_only, both, as_tag_only = three
    _1 = alternative.basename
    _2 = len(as_feature_only)
    _3 = ', '.join(both)
    _4 = len(as_tag_only)
    return f'{_1} {_2}:({_3}):{_4}'


def _join(s_a):
    _ = ', '.join(s_a)
    return f'({_})'


# --

if __name__ == '__main__':
    import sys
    _me = sys.modules[__name__]
    from all import CLI_for_Report as _
    _CLI = _(_me)
    o = sys
    _exitstatus = _CLI(o.stdin, o.stdout, o.stderr, o.argv).execute()
    exit(_exitstatus)

# #born.
