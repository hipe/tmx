require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - synchronize edges" do

    TS_[ self ]
    use :memoizer_methods
    use :fixture_files
    use :output_adapters_quickie

    context "(no formatting)" do

      it "an output document (lines) is generated" do
        _many_lines || fail
      end

      it "the output document vaguely looks structurally right" do
        _index || fail
      end

      it "both nodes came thru" do
        bx = _index
        bx.has_name "money" or fail
        bx.fetch "wummy mummy" or fail
      end

      it "(each byte)" do

        _expect = <<-HERE.unindent
          describe "winzoorz" do

            it "money" do
              :oney.should eql funny
            end

            it "wummy mummy" do
              jimbo( :jambo ).should eql jamboree
            end
          end
        HERE

        _e = line_stream_via_string_ _expect
        _a = Common_::Stream.via_nonsparse_array _many_lines
        expect_actual_line_stream_has_same_content_as_expected_ _a, _e
      end

      shared_subject :_index do

        a = _many_lines.dup
        a.first == "describe \"winzoorz\" do\n" || fail
        a.last == "end\n" || fail
        a.pop
        _big_s = a.join
        o = begin_simple_chunker_for_ _big_s
        o.skip_a_postseparated_chunk
        o.to_box
      end

      shared_subject :_many_lines do

        o = begin_forwards_synchronization_session_for_tests_

        o.choices = real_default_choices_

        path = fixture_tree_pather 'tree-02-little-formatting'

        o.asset_path = path[ 'asset.whootily.rb' ]

        o.original_test_path = path[ 'original.test.whootily.rb' ]

        o.to_line_stream.to_a
      end
    end
  end
end
