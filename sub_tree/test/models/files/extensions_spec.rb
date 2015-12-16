require_relative '../../test-support'

module Skylab::SubTree::TestSupport

  describe "[st] models - files - extensions" do

    TS_[ self ]
    use :expect_event
    use :models_files

    _MTIME = "\\d+ [acdehikmnorswy]{1,3}"

    it "an in-notify extension - `mtime` (writes to output stream)" do

      io = build_string_IO
      _path = fixture_tree :one

      Home_::Library_::FileUtils.cd _path do  # not necessary, just prettier

        call_API :files, :mtime,
          :path, [ '.' ],
          :output_stream, io
      end

      scn = TestSupport_::Expect_Line::Scanner.via_string io.string
      scn.next_line.should eql ".\n"
      scn.next_line.should match %r(\A├── foo.rb #{ _MTIME }$)
      scn.next_line.should match %r(\A└── test$)
      scn.next_line.should match %r(\A    └── foo_speg\.rb #{ _MTIME }$)
      scn.next_line.should be_nil

      expect_succeeded
    end

    it "a multi-buffer extension - `line count` (results in table renderer)" do

      io = build_string_IO

      Home_::Library_::FileUtils.cd fixture_tree :one do

        call_API :files, :line_count,
          :path, [ '.' ],
          :output_stream, io
      end

      _expect_only_informational_events

      st = @result.to_line_stream

      io.string.should eql EMPTY_S_

      st.gets.should eql ".                          \n"
      st.gets.should eql "├── foo.rb           1 line\n"
      st.gets.should eql "└── test                   \n"
      st.gets.should eql "    └── foo_speg.rb  1 line\n"
      st.gets.should be_nil
    end

    it "a in-notify extension and a multi-buffer extension (results in t.r)" do

      io = build_string_IO

      Home_::Library_::FileUtils.cd fixture_tree :one do

        call_API :files, :mtime, :line_count,
          :path, [ '.' ],
          :output_stream, io
      end

      io.string.should eql EMPTY_S_

      _expect_only_informational_events

      st = @result.to_line_stream

      st.gets.should match %r(\A\.[ ]+\n\z)

      st.gets.should match %r(\A├── foo\.rb[ ]+#{ _MTIME } 1 line[ ]*\n\z)

      st.gets.should match %r(\A└── test[ ]+\n\z)

      st.gets.should match %r(\A    └── foo_speg\.rb  #{ _MTIME } 1 line[ ]*\n\z)

      st.gets.should be_nil
    end

    def _expect_only_informational_events

      _ = @event_log.gets
      :wordcount_command == _.channel_symbol_array.last or fail

      _ = @event_log.gets
      :find_exitstatus == _.channel_symbol_array.last or fail

      expect_no_more_events

      NIL_
    end
  end
end
