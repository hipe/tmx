require_relative '../../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] tree - magnetics - `longest_common_base_path`" do

    TS_[ self ]
    use :tree

      it "(does paths to tree and vice-versa)" do

        _from_paths = [
          'a',
          'bb/cc/dd',
          'bb/cc',
          'bb/cc/dd/ee'
        ].freeze

        _tree = subject_module_.via :paths, _from_paths
        _paths = __paths_via_tree _tree
        _paths == %w(
          a
          bb/
          bb/cc/
          bb/cc/dd/
          bb/cc/dd/ee
        ) || fail
      end

      it "when empty" do
        against EMPTY_A_
        want nil
      end

      it "when 1x1" do
        against %w(one)
        want %w(one)
      end

      it "when 1x2" do
        against %w(one/two)
        want %w(one two)
      end

      it "when 1x3" do
        against %w(one/two/three)
        want %w(one two three)
      end

      it "when 2x1 (different)" do
        against %w(one two)
        want nil
      end

      it "when 2x1 (same)" do
        against %w(yup yup)
        want %w(yup)
      end

      it "when 2x2 (some)" do
        against %w(a/b a/c)
        want %w(a)
      end

      it "when 2x2 (none)" do
        against %w(x/a y/a)
        want nil
      end

      it "when 2x2 (all)" do # actually should become 1x2
        against %w(p/q p/q)
        want %w(p q)
      end

      it "when 3x3 (some)" do
        against %w(a/b/c a/b/f/g a/b/f/h a/b/l/m/n)
        want %w(a b)
      end

      def against s_a
        @s_a = s_a
      end

      def want s_a

        _ = subject_module_.via :paths, @s_a
        _act = _.longest_common_base_path
        _act == s_a || fail
      end

      def __paths_via_tree t
        t.to_stream_of( :paths ).to_a
      end

  end
end
