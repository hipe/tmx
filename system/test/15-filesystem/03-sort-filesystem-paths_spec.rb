require_relative '../test-support'

module Skylab::System::TestSupport

  describe "[sy] - filesystem - sort filesystem paths" do

    TS_[ self ]
    # use :memoizer_methods

    def self.given_paths & p
      define_method :_argument_paths, & p
    end

    context "minimal interesting" do
      given_paths do
        ['aaa', 'ccc', 'bbb']
      end

      it "sorts paths in lexcial order" do
        expect_paths 'aaa', 'bbb', 'ccc'
      end

      it "sorts entries in lexical order" do
        expect_entries 'aaa', 'bbb', 'ccc'
      end
    end

    context "uppercase AFTER lowercase" do
      given_paths do
        [ 'EE', 'dd', 'BB', 'aa' ]
      end

      it "with entries" do
        expect_entries 'aa', 'dd', 'BB', 'EE'
      end
    end

    context "(regression for next case - ruby String.split is kinda dumb)" do

      given_paths do
        [ "zubba/", "zubba" ]
      end

      it "sorts in preorder" do
        expect_paths "zubba", "zubba/"
      end
    end

    context "the dir itself before its children (preorder not in- or post-)" do

      given_paths do
      [ "zubba/two",
        "zubba/",
        "zubba/one",
        "fubba/dee",
        "zubba",
        "fubba/doo" ]
      end

      it "sorts in preorder" do
        expect_paths(
          "fubba/dee",
          "fubba/doo",
          "zubba",
          "zubba/",
          "zubba/one",
          "zubba/two" )
      end
    end

    context "dots how we want them" do
      given_paths do
      [ 'boo',
        '..',
        'far',
        '.',
        '.jazzmatazz' ]
      end

      it "single dot before double dot before dotfiles (NOTE)" do

        # NOTE: - we suspect this is not the order that OS X expresses
        # but we can't test it right now and it might be out of scope

        expect_entries(
          '.',
          '..',
          '.jazzmatazz',
          'boo',
          'far')
      end
    end

    def expect_paths * expected_paths
      arg1 = _argument_paths
      act = subject_module::Maybe_sort_filesystem_paths[arg1]
      expect(act).to eq(expected_paths)
    end

    def expect_entries * expected_entries
      arg1 = _argument_paths
      arg1.each do |x|
        if x.include? ::File::SEPARATOR
          raise "oops, should be entry: #{ x }"
        end
      end
      act = subject_module::Maybe_sort_filesystem_entries[arg1]
      expect(act).to eq(expected_entries)
    end

    def subject_module
      Home_::Filesystem::UbuntuPathSorter__
    end
  end
end
# #born
