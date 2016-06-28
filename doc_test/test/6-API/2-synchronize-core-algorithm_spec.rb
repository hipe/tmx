require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - synchronize core algorithm" do

    TS_[ self ]
    use :memoizer_methods
    use :fixture_files
    use :output_adapters_quickie

    # about its placement: this test file exists squarely to test
    # [#017]:#the-forwards-synchronization-algorithm, which is implemented
    # as a magnetic. test files that test these topmost-level magnetics
    # typically go in the magnetics test node, but this file is instead
    # here because it integrates (and relies upon) so many other components
    # (magnetic and non-magnetic alike). as such, it is both more clear from
    # a conceptual standpoint and more valuable from a regression standpoint
    # to place the file here. (also an imaginary "operations" node overlaps
    # with the "API" node of tests.
    # (assumes [#ts-001].C test numbering conventions.)

    it "loads" do
      _subject_magnetic
    end

    it "an output document (lines) is generated" do
      _big_string || fail
    end

    it "the output document vaguely looks structurally right" do
      _index || fail
    end

    _THIS_MARGIN = ' ' * 8

    # from the doc:
    # A D B C E
    # 0 1 2 3 4

    it "nonexistent, leading node is added at head" do  # #coverpoint3-1

      o = _index.fetch "this is test A"
      o.index == 0 || fail
      o.num_trailing_lines == 1 || fail
      o.full_string.include?(
        "\n#{ _THIS_MARGIN }( this( :will ).become ).should eql :the_first_example"
      ) || fail
    end

    it "existed in target" do

      # #coverpoint3-4:

      bx = _index
      o = bx.fetch "this is test D"
      o.index == 1 || fail

      # #coverpoint3-2:

      o = bx.fetch "this is test B"
      o.index == 2 || fail
      o.num_trailing_lines == 1 || fail
      o.full_string.include?(
        "\n#{ _THIS_MARGIN }( this( :will ).replace ).should eql :what_was_in_test_B"
      ) || fail
    end

    it "did not exist in target, was not first to be inserted, goes after X" do  # #coverpoint3-3

      bx = _index
      o = bx.fetch "this is test C"
      o.index == 3 || fail
      o.num_trailing_lines == 1 || fail
      # meh content

      o = bx.fetch "this is test E"
      o.index == 4 || fail
    end

    shared_subject :_index do

      _big_s = _big_string

      _md = %r(\A
        module[ ]AnythingThisIsNeverLoaded\n
        \n
        [ ]{2,2}module[ ]AsManyMoreModulesAsYouLike\n
        \n
        [ ]{4,4}describe[ ]"mami"[ ]do\n
        \n
        (?<tons_o_stuff> .+ )
        [ ]{4,4}end\n
        [ ]{2,2}end\n
        end\n
      \z)mx.match _big_s

      o = begin_simple_chunker_for_ _md[ :tons_o_stuff ]
      o.skip_a_postseparated_chunk  # comments
      o.to_box
    end

    shared_subject :_big_string do

      o = begin_forwards_synchronization_session_for_tests_

      o.choices = real_default_choices_

      path = fixture_tree_pather 'tree-01'

      o.asset_path = path[ 'asset.fake.rb' ]

      o.original_test_path = path[ 'original.test.fake.rb' ]

      o.to_string
    end

    def _subject_magnetic
      forwards_synchronization_magnetic_module_
    end
  end
end
# #pending-rename: see big comment in this file.
