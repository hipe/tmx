require_relative '../../test-support'

module Skylab::SubTree::TestSupport

  describe "[st] operations - files - extensions" do

    TS_[ self ]
    use :want_event
    use :operations_files

    _MTIME = "\\d+ [acdehikmnorswy]{1,3}"

    it "an in-notify extension - `mtime` (writes to output stream)" do

      io = build_string_IO
      _path = fixture_tree :one

      Home_::Library_::FileUtils.cd _path do  # not necessary, just prettier

        call_API :files, :mtime,
          :path, [ '.' ],
          :output_stream, io
      end

      _st = Home_.lib_.basic::String::LineStream_via_String.call io.string

      want_these_lines_in_array_ _st do |y|
        y << ".\n"
        y << %r(\A├── foo.kode #{ _MTIME }$)
        y << %r(\A└── test$)
        y << %r(\A    └── foo_speg\.kode #{ _MTIME }$)
      end

      want_succeed
    end

    it "a multi-buffer extension - `line count` (results in table renderer)" do

      io = build_string_IO

      Home_::Library_::FileUtils.cd fixture_tree :one do

        call_API :files, :line_count,
          :path, [ '.' ],
          :output_stream, io
      end

      _want_only_informational_events

      _st = @result.to_line_stream

      expect( io.string ).to eql EMPTY_S_

      want_these_lines_in_array_with_trailing_newlines_ _st do |y|
        y << '.                            '
        y << '├── foo.kode           1 line'
        y << '└── test                     '
        y << '    └── foo_speg.kode  1 line'
      end
    end

    it "a in-notify extension and a multi-buffer extension (results in t.r)" do

      io = build_string_IO

      Home_::Library_::FileUtils.cd fixture_tree :one do

        call_API :files, :mtime, :line_count,
          :path, [ '.' ],
          :output_stream, io
      end

      expect( io.string ).to eql EMPTY_S_

      _want_only_informational_events

      _st = @result.to_line_stream

      want_these_lines_in_array_ _st do |y|

        y << %r(\A\.[ ]+\n\z)

        y << %r(\A├── foo\.kode[ ]+#{ _MTIME } 1 line[ ]*\n\z)

        y << %r(\A└── test[ ]+\n\z)

        y << %r(\A    └── foo_speg\.kode  #{ _MTIME } 1 line[ ]*\n\z)
      end
    end

    def _want_only_informational_events

      _ = @event_log.gets
      :wordcount_command == _.channel_symbol_array.last or fail

      _ = @event_log.gets
      :find_exitstatus == _.channel_symbol_array.last or fail

      want_no_more_events

      NIL_
    end
  end
end
