# frozen_string_literal: true

require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe '[ac] git config magnetics - pluralton components index via existing document index' do

    TS_[ self ]
    use :memoizer_methods
    use :git_config_magnetics

    it 'subject magnetic loads' do
      magnet_200_ || fail
    end

    context '(doing my part for story A)' do

      it 'none of the components appears more than once in this one index' do
        _max_number_of_occurrences = _this_one_index[0]
        _max_number_of_occurrences == 1 || fail
      end

      it 'the components that are also in the document appear in the index' do
        _h = _this_one_index[1]
        _expected = %i( D C A A_prime E F )  # all but one, from #here2
        _missing = _expected - _h.keys
        _missing.length.zero? || fail
      end

      it 'the component that is NOT in the document does not appear in the index' do
        h = _this_one_index[1]
        h[ :A ] || fail  # (local sanity check)
        h[ :Q ] && fail
      end

      it %q(then there's this guy) do
        number_of_nils, number_of_not_nils = _build_this_other_index  # SEE
        number_of_nils == 3 || fail
        number_of_not_nils == 6 || fail
      end

      shared_subject :_this_one_index do
        _build_this_one_index
      end

      alias_method :_subject, :product_of_magnetic_200_for_story_A_
    end

    def _build_this_other_index  # #coverpoint2.4

      # the index "member" that we're testing traces the "schematic"
      # structure of the document by relating the sections within clusters
      # to items in the other array:
      #
      #     [[2, 3], [nil, 1, nil, nil, 0], [4, 5]]
      #
      # the `nil`s are sections that *are* participating but where their
      # would-be entities are not present in the new component list (i.e
      # they should be removed.)
      #
      # the non-`nil`s are offset references to the *other* member array
      # in the subject. THESE items, in turn, can point you back to the
      # new components (and are the subject of other tests in this file).

      number_of_nils = 0
      number_of_not_nils = 0

      locators = _first_member_of_the_index

      _d_a_a = _second_member_of_the_index
      _d_a_a.each_with_index do |d_a, clust_d|
        d_a.each_with_index do |d, offset_in_clust_d|
          if d
            _assocd_locs = locators.fetch d
            act_clust_d, act_offset_in_clust_d = _assocd_locs.document_locator
            act_clust_d == clust_d || fail
            act_offset_in_clust_d == offset_in_clust_d || fail
            number_of_not_nils += 1
          else
            number_of_nils += 1
          end
        end
      end

      [ number_of_nils, number_of_not_nils ]
    end

    def _build_this_one_index  # #coverpoint2.3

      # obnoxiously, we won't build any of the assumptions deeply into
      # how we build the index ..

      # to review this one story, these are those in the component list:
      #
      #     D  Q  C  A  A'  E  F
      #
      # these are those in the document:
      #
      #     A A'  |  B C C' C'' D  |  E F
      #
      #
      # (`X'`, `X''` and so on (pronounced "X-prime", "X-prime-prime") is
      # an identical `X` that is a separate, distinct (yet fungible) entity.)
      #

      current_max = 0
      counts = {}

      these = %i( D Q C A A_prime E F )
        # these must corresond to the component list there in our coverpoint

      _locs = _first_member_of_the_index
      _locs.each do |locators|
        _d = locators.component_locator
        k = these.fetch _d
        candidate_max = ( counts[k] || 0 ) + 1
        counts[k] = candidate_max
        candidate_max > current_max and current_max = candidate_max
      end

      [ current_max, counts ]
    end

    def _first_member_of_the_index
      _subject.associated_locators
    end

    def _second_member_of_the_index
      _subject.associated_locator_offsets_schematic
    end

    # ==

    # ==
    # ==
  end
end
# #born (to cover work that was stashed ~6 months ago)
