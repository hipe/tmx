require_relative '../../test-support'

module Skylab::SubTree::TestSupport

  describe "[st] models - files - extensions" do

    TS_[ self ]
    use :expect_event
    use :models_files

    _MTIME = "\\d+ [acdehikmnorswy]{1,3}"

    it "an in-notify extension - `mtime`" do

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

    it "a multi-buffer extension - `line count`" do

      io = build_string_IO

      Home_::Library_::FileUtils.cd fixture_tree :one do

        call_API :files, :line_count,
          :path, [ '.' ],
          :output_stream, io
      end

      st = _skip_informational_events_and_get_to_table_line_stream

      io.string.should eql EMPTY_S_

      st.gets.should eql ".                          \n"
      st.gets.should eql "├── foo.rb           1 line\n"
      st.gets.should eql "└── test                   \n"
      st.gets.should eql "    └── foo_speg\.rb  1 line\n"

      expect_succeeded
    end

    it "a in-notify extension and a multi-buffer extension" do

      io = build_string_IO

      Home_::Library_::FileUtils.cd fixture_tree :one do

        call_API :files, :mtime, :line_count,
          :path, [ '.' ],
          :output_stream, io
      end

      io.string.should eql EMPTY_S_

      st = _skip_informational_events_and_get_to_table_line_stream

      st.gets.should match %r(\A\.[ ]+\n\z)

      st.gets.should match %r(\A├── foo\.rb[ ]+#{ _MTIME } 1 line[ ]*\n\z)

      st.gets.should match %r(\A└── test[ ]+\n\z)

      st.gets.should match %r(\A    └── foo_speg\.rb  #{ _MTIME } 1 line[ ]*\n\z)

      st.gets.should be_nil

      expect_succeeded
    end

    def _skip_informational_events_and_get_to_table_line_stream

      @ev_a[ 0 .. -2 ] = EMPTY_A_  # HACK: skip any informationals here

      ev = expect_neutral_event :result_table

      ev and begin
        Callback_::Stream.via_nonsparse_array black_and_white_lines ev
      end
    end
  end
end
