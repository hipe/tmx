require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] CLI - recursive intro" do

    TS_[ self ]
    use :memoizer_methods
    use :my_non_interactive_CLI

    _OP = 'recur'

    context "list (self)" do

      given do
        argv _OP, '--list', sidesystem_path_
      end

      it "succeeds" do
        succeeds
      end

      shared_subject :_sorted_tuples do
        __sort_these_tuples to_output_line_stream
      end

      it "first result is for the top thing, test file not exist (#FRAGILE)" do

        c_or_d, test_path, asset_path = _sorted_tuples.fetch 0
        c_or_d == :create || fail
        test_path == "test/core_spec.rb" || fail
        asset_path == 'doc_test.rb' || fail
      end

      it "second thing is etc (#FRAGILE)" do

        c_or_d, test_path, asset_path = _sorted_tuples.fetch 1
        c_or_d == :update || fail

        asset_path.include? '/recursion-magnetics-/' or fail

        # be jerks
        digislug = '\d+(?:\.\d+)*(?:-[a-z]+)+'
        test_path =~ %r(\Atest(?:/#{ digislug })+/#{ digislug }_spec\.rb\z) || fail
      end
    end

    _preview_done_rx = %r(\A\(preview for one file done \(\d+ lines)

    _NOUN_STEM = 'test document generation'

    it "does the dry run that generates fake bytes omg", wip: true do  # #old-wip:2015-04

      invoke 'recursive', '--sub-act', 'preview', common_path

      on_stream :errput

      expect  %r(\Acurrent output path -)

      _d = count_contiguous_lines_on_stream :output
      ( 29 .. 33 ).should be_include _d

      expect _preview_done_rx
      expect %r(\Acurrent output path -)

      _d = count_contiguous_lines_on_stream :output
      ( 45 .. 49 ).should be_include _d

      expect _preview_done_rx
      expect "(2 #{ _NOUN_STEM }s total)"

      expect_no_more_lines

      @exitstatus.should be_zero
    end

    it "requires force to overwrite", wip: true do  # #old-wip:2015-04

      invoke 'recursive', '--dry-run', common_path

      on_stream :errput

      expect :styled, /\Acouldn't .+ generate .+ because .+ exists, won't/
      expect "(0 #{ _NOUN_STEM }s total)"
      expect_no_more_lines

    end

    it "money", wip: true do  # #old-wip:2015-04

      invoke 'recursive', '--forc', '--dry-run', common_path

      on_stream :errput
      expect %r(\Aupdating [^ ]+/final/top_spec\.rb \.\. done \(\d+ lines\b)
      expect %r(\Aupdating [^ ]+/integration/core_spec\.rb \.\. done \(\d+ lines\b)
      expect "(2 #{ _NOUN_STEM }s total)"
      expect_no_more_lines

    end

    alias_method :common_path, :home_dir_path_

    def __sort_these_tuples output_line_stream

      _ETC = {
        'would-create' => :create,
        'would-update' => :update,
      }
      _SPACE = ' '  # SPACE_

      o = Home_.lib_.basic::Pathname::Localizer
      localize_asset = o[ ::File.dirname( home_dir_path_ ) ]
      localize_test = o[ sidesystem_path_ ]

      tuples = output_line_stream.map_by do |str|
        c_or_d, test_path, asset_path = str.split _SPACE
        [ _ETC.fetch( c_or_d ), localize_test[ test_path ], localize_asset[ asset_path ] ]
      end.to_a

      tuples.sort_by! do |tuple|
        tuple.last.length
      end

      tuples
    end
  end
end
# #tombstone: began to remove pre-zerk test cases
