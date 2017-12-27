require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[ac] git config magnetics - capsulization via reallocation schema" do

    TS_[ self ]
    use :memoizer_methods
    use :git_config_magnetics

    it 'loads' do
      magnet_400_ || fail
    end

    context 'story B (easy)' do  # #coverpoint2.5

      it 'calls' do
        _result || fail
      end

      it 'the capsule clusterization looks right' do

        cc = _result.capsule_clusterization
        cc.length == 2 || fail

        p = _capsule_clusterization_tinger_for cc

        p[ 0, nil, [0, 0], nil, [1, 0] ]
        p[ 1, [1, 1], nil, [2, 0], nil, [3, 0]]
      end

      it 'capsules looks right' do

        # (we come from the outside in, spiraling down progressively)

        # follow the coverpoint into the suport file to see what the offsets mean

        caps = _result.capsules
        caps.length == 4 || fail

        p = _capsules_thinger_for caps
        p[ 0, [ 0, 1 ]]
        p[ 1, [ 0, 3 ], [ 1, 0 ]]
        p[ 2, [ 1, 2 ]]
        p[ 3, [ 1, 4 ]]
      end

      def _result
        _story_B_result
      end
    end

    context 'story C (easy)' do  # #coverpoint2.6

      it 'calls' do
        _result || fail
      end

      it 'the capsule clusterization looks right' do

        cc = _result.capsule_clusterization
        cc.length == 5 || fail

        # (we didn't narratize this below but note that there is one capsule)

        p = _capsule_clusterization_tinger_for cc
        p[ 0, nil, [0, 0]]
        p[ 1, [0, 1]]
        p[ 2, [0, 2]]
        p[ 3, [0, 3]]
        p[ 4, [0, 4], nil]
      end

      it 'capsules looks right' do

        # follow the coverpoint into the support file to see what the offsets mean

        caps = _result.capsules
        caps.length == 1 || fail

        p = _capsules_thinger_for caps
        p[ 0,
          [ 0, 1 ],
          [ 1, 0 ],
          [ 2, 0 ],
          [ 3, 0 ],
          [ 4, 0 ],
        ]
      end

      def _result
        _story_C_result
      end
    end

    def _story_B_result
      product_of_magnetic_400_for_story_B_
    end

    def _story_C_result
      product_of_magnetic_400_for_story_C_
    end

    # --

    def _capsule_clusterization_tinger_for cc
      -> i, * these do
        o_a = cc.fetch i
        o_a.length == these.length || fail
        these.each_with_index do |a, d|
          if a
            capsule_reference = o_a.fetch d
            capsule_reference.capsule_offset == a.fetch( 0 ) || fail
            capsule_reference.offset_into_capsule == a.fetch( 1 ) || fail
          else
            o_a[d] && fail
          end
        end
      end
    end

    def _capsules_thinger_for caps
      -> offset, * d_a_a do
        capsule = caps.fetch offset
        a = capsule.cluster_locators
        a.length == d_a_a.length || fail
        d_a_a.each_with_index do |(d, d_), i|
          o = a.fetch i
          o.cluster_offset == d or fail "at #{i}.A need #{d} had #{ o.cluster_offset }"
          o.cluster_element_offset == d_ or fail "at #{i}.B} need #{d_} had #{ o.cluster_element_offset }"
        end
      end
    end

    # ==
    # ==
  end
end
# #born. (based on work in a stash from ~6 months earlier)
