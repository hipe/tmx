require_relative '../test-support'

module Skylab::System::TestSupport

  describe "[sy] diff" do

    # three laws

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject_service || fail
    end

    context "the normalest, target use case diff (two chunks)" do

      it "builds" do
        _VOLATILE || fail
      end

      it "knows it is not empty" do
        _state_one_after_not_empty_check.first && fail
      end

      it "hunk stream - make sense (regression)" do

        # (just as a fun aside of a case study, we accidentally had `||=`
        # when we meant `!=` and so every hunk never had any more than
        # one line; but remarkably this nonetheless worked "fine")
        # #history-A.1

        _diff = _state_one_after_not_empty_check.last

        st = _diff.to_hunk_stream
        _h1 = st.gets
        _h2 = st.gets
        _h3 = st.gets
        _h4 = st.gets
        _h4 && fail

        _h1.category_symbol == :diff_header || fail
        _h2.category_symbol___ == :hunk || fail
        _h3.category_symbol___ == :hunk || fail

        _h2.instance_variable_get( :@_runs ).length == 3 || fail
        _h3.instance_variable_get( :@_runs ).length == 4 || fail
      end

      it "back to line stream again (almost byte-per-byte)" do
        _guy = _state_one_after_not_empty_check.last
        act_st = _guy.to_line_stream

        s = act_st.gets
        s_ = act_st.gets

        s =~ %r(\A--- ) || fail
        s_ =~ %r(\A\+\+\+ ) || fail

        _exp_str = <<-HERE.unindent
          @@ -1,3 +1,4 @@
          +l1
           l2
           l3
           l4
          @@ -5,5 +6,4 @@
           l6
           l7
           l8
          -l9
           l10
        HERE

        lib = TestSupport_::Want_Line

        _exp_st = Basic_[]::String::LineStream_via_String[ _exp_str ]

        lib::Streams_have_same_content[ act_st, _exp_st, self ]
      end

      shared_subject :_state_one_after_not_empty_check do
        diff = _VOLATILE
        [ diff.is_the_empty_diff, diff ]
      end

      shared_subject :_VOLATILE do

        _file_one = Home_::Stream_[ %w( l2 l3 l4 l5 l6 l7 l8 l9 l10 ) ]
        _file_two = Home_::Stream_[ %w( l1 l2 l3 l4 l5 l6 l7 l8 l10 ) ]

        _subject_service.by do |o|
          o.left_line_stream = _file_one
          o.right_line_stream = _file_two
        end
      end
    end

    context "against two real files (not line streams) and they are identical" do

      it "builds" do
        _VOLATILE || fail
      end

      it "knows it is empty" do
        _state_one_after_not_empty_check.first || fail
      end

      shared_subject :_state_one_after_not_empty_check do
        diff = _VOLATILE
        [ diff.is_the_empty_diff, diff ]
      end

      shared_subject :_VOLATILE do

        # here is [#008.1] where we expect the below two files to be selfsame

        dir = TestSupport_::Fixtures.tree :one

        _left_path = ::File.join dir, 'test', 'foo_speg.kode'
        _right_path = ::File.join dir, 'foo.kode'

        _subject_service.by do |o|
          o.left_file_path = _left_path
          o.right_file_path = _right_path
        end
      end
    end

    def _subject_service
      services_.diff
    end
  end
end
# :#history-A.1 (as referenced)
