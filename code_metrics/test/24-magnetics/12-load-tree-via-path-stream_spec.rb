require_relative '../test-support'

module Skylab::CodeMetrics::TestSupport

  describe "[cm] magnetics (private) - load tree via path stream" do

    TS_[ self ]
    use :memoizer_methods
    use :treemap_node

    it "loads" do
      _subject
    end

    context "shimmy" do

      given_request do |o|
        o.head_path = '/a'
      end

      given_expanded_path_stream do |y|
        y << '/a/one.x'
        y << '/a/one/two.x'
      end

      it "builds" do
        load_tree_ || fail
      end

      it "knows that has children" do
        load_tree_.has_children || fail
      end

      it "wee (same order)" do
        _same_order
      end
    end

    context "shake (identical to shimmy but for the order of the paths)" do

      given_request do |o|
        o.head_path = '/a'
      end

      given_expanded_path_stream do |y|
        y << '/a/one/two.x'
        y << '/a/one.x'
      end

      it "wee (same order)" do
        _same_order
      end
    end

    def _same_order
      _expect_normal_paths do |y|
        y << %w( one )
        y << %w( one two )
      end
    end

    # -- expectations

    def _expect_normal_paths
      st = load_tree_.to_pre_order_normal_path_stream
      _y = ::Enumerator::Yielder.new do |s_a|
        act_s_a = st.gets
        act_s_a == s_a || fail
      end
      yield _y
      extra_s_a = st.gets
      extra_s_a && fail
    end

    # -- setup support

    def event_listener_
      NOTHING_
    end

    def _subject
      Home_::Magnetics_::LoadTree_via_PathStream
    end
  end
end
