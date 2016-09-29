require_relative '../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - synchronize intro" do

    TS_[ self ]
    use :fixture_files
    use :my_API

    context 'o.a strange name' do

      call_by do
        my_API_common_generate_(
          output_adapter: :wazoozle,
          asset_line_stream: :x,
        )
      end

      it 'fails' do
        fails
      end

      it 'expresses' do

        _be_this = be_emission_ending_with :uninitialized_constant do |ev|
          _rx = /\Auninitialized constant .+\( ~ wazoozle \)\z/
          black_and_white( ev ) =~ _rx or fail
        end

        only_emission.should _be_this
      end
    end

    context 'no exampular code runs'

    context 'first working case' do

      call_by do

        _asset_path = fixture_tree_pather( 'tree-02-little-formatting' )[ 'asset.whootily.kode' ]

        my_API_common_generate_(
          asset_line_stream: open( _asset_path ),
        )
      end

      it 'produces something' do
        root_ACS_result || fail
      end

      it 'emits nothing' do
        expect_no_emissions
      end

      it 'content looks right (most bytes)' do

        _line_stream = root_ACS_result

        o = begin_expect_line_scanner_for_line_stream_ _line_stream

        o.next_line
        o.line == "require_relative 'test-support'\n" || fail

        o.blank_line_then %r(\Amodule YourModuleHere\b)

        o.blank_line_then %r(\A  describe "[^"]+" do\n\z)

        # o.blank_line_then %r(\A  TS_\[ self \])  # you would want it wouldn't you #open [#032]

        _info = scan_all_examples_ o

        _info.example_count == 2 || fail

        o.expect_that_line_matches "  end\n"

        o.expect_that_next_line_matches "end\n"

        o.expect_no_more_lines
      end
    end

    # rather than do the absurd, ugly (but high-novelty) trick of generating
    # the same test that you run, we break it down into smaller pieces that
    # regress better:
    #
    # there is the asset file that has an embedded test, and there is a test
    # here that has the the same bytes that that example should generate.
    #
    #   1) in one example written here we make sure that the bytes generated
    #      from the asset file line up with the bytes we already have written
    #      here in the test file.
    #
    #   2) in another, dedicated example here, we make sure that the example
    #      written here passes. (er, we just run that example.)
    #
    # in this way we ensure (more-or-less) that what the embedded test
    # expresses is valid, but in a manner that is much easier to maintain
    # than the old way.

    context "(bytes of The Example)" do

      # also #coverpoint4-1 - blank lines in code run
      # also #coverpoint4-2 - match string head magic pattern

      call_by do

        _path = home_asset_file_path_

        my_API_common_generate_(
          asset_line_stream: open( _path ),
        )
      end

      it "(bytes)" do

        same_rx = %r(\bthe minimal interesting example for calling the API\b)
        same_end = "    end\n"

        # -- run against the real asset file, slice out the generated bytes

        _st = root_ACS_result

        o = begin_expect_line_scanner_for_line_stream_ _st

        o.advance_to_next_rx same_rx

        o.skip_blank_lines  # regrettably none

        actual = o.buffer_until_line same_end

        actual.unindent

        # -- slice out the "real" bytes we hand-typed here in this selfsame file

        o = begin_expect_line_scanner_for_line_stream_ open __FILE__

        o.advance_to_next_rx same_rx

        o.skip_blank_lines  # here one

        expected = o.buffer_until_line same_end

        expected.unindent

        # -- compare the two

        expect_actual_big_string_has_same_content_as_expected_ actual, expected
      end
    end

    # (don't alter the below example without understanding the above -
    #  where it "lives" is at the top asset file of this project.)

    it "the minimal interesting example for calling the API" do

      _path = "#{ DocTest.dir_path }.rb"

      st = DocTest::API.call(
        :synchronize,
        :asset_line_stream, open( _path ),
        :output_adapter, :quickie,
      )

      st.gets.should match %r(\Arequire_relative\ )
      st.gets  # blank line..
      # ..
    end
  end
end
# #history: big rewrite of this file, sunset sibling self-rewriting test
