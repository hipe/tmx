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

      blank_lines = %r(\n+)
      describe_rx = /^ +it "([^"]+)"/
      nonblank_lines = %r((?:[ ]+[^ ].+\n)+)

      bx = Common_::Box.new
      scn = ::StringScanner.new _md[ :tons_o_stuff ]

      s = scn.scan nonblank_lines
      s or fail  # comments. toss it out
      d = scn.skip blank_lines
      d.zero? && fail

      index = -1
      begin

        s = scn.scan nonblank_lines
        md = describe_rx.match s

        d = scn.skip blank_lines

        index += 1
        key = md[ 1 ]

        if d
          o = X_Ting___.new( key, index, d, s )
          bx.add o.description_string, o
          redo
        end
        o = X_Ting___.new( key, index, 0, s )
        bx.add o.description_string, o
        scn.eos? or Home_._SANITY
        break
      end while nil

      bx
    end

    X_Ting___ = ::Struct.new :description_string, :index, :num_trailing_lines, :full_string

    shared_subject :_big_string do

      # -- setup variables for magnetics

      cx = real_default_choices_

      path = fixture_tree_pather 'tree-01'

      in_fh = ::File.open path[ 'asset.fake.rb' ]

      orig_fh = ::File.open path[ 'original.test.fake.rb' ]

      # -- run through the magnetics & related (near [#ta-005])

      o = magnetics_module_

      _bs = o::BlockStream_via_LineStream_and_Single_Line_Comment_Hack[ in_fh ]

      node_st = o::NodeStream_via_BlockStream_and_Choices[ _bs, cx ]

      test_doc = output_adapter_test_document_parser_.parse_line_stream orig_fh
      orig_fh.close

      # --

      o = _subject_magnetic.begin
      o.choices = cx
      o.node_stream = node_st
      o.test_document = test_doc
      doc = o.finish
      in_fh.close

      # --

      doc.to_line_stream.reduce_into_by "" do |m, s|
        m << s
      end
    end

    def _subject_magnetic
      magnetics_module_::TestDoc_via_NodeStream_and_TestDoc_and_Choices
    end
  end
end
# #pending-rename: see big comment in this file.
