require_relative 'test-support'

module Skylab::SubTree::TestSupport::Models_Files

  describe "[st] models - files - upstream adapters" do

    Callback_.test_support::Expect_event[ self ]

    extend TS_

    it "stdin and file - can't read from both stdin and file" do

      call_API :files,
        :file_of_input_paths, :x,
        :input_stream, MOCK_NONINTERACTIVE_IO_,
        :output_stream, :x

      _ev = expect_not_OK_event

      black_and_white( _ev ).should match(
        /\Acan't read input from both #{
          }[^a-z]*file-of-input-paths[^a-z ]*#{
          } and #{
          }[^a-z]*input-stream[^a-z ]*#{
          } at the same time/i )

      expect_failed
    end

    it "file and one path - can't read from both path and file" do

      call_API :files,
        :file_of_input_paths, :x,
        :path, [ :x ],
        :output_stream, :x

      _ev = expect_not_OK_event

      _ev.to_event.a.map( & :name_symbol ).should eql(
        [ :file_of_input_paths, :path ] )

      expect_failed
    end

    it "all three - can't read from a, b, and c" do

      call_API :files, :path, [ 'a' ],
        :file_of_input_paths, :x,
        :input_stream, MOCK_NONINTERACTIVE_IO_,
        :output_stream, :x

      _ev = expect_not_OK_event

      black_and_white( _ev ).should eql(
        "can't read input from #{
        }«file-of-input-paths»#{
        }, #{
        }«path»#{
        } and #{
        }«input-stream»#{
        } at the same time" )
      expect_failed
    end

    it "reads from an open filehandle" do

      io = build_string_IO

      fh = ::File.open fixture_file( :one_find ), ::File::RDONLY

      call_API :files, :input_stream, fh, :output_stream, io

      expect_succeeded

      io.string.should eql PRETTY_

      fh.should be_closed
    end

    it "reads paths from the lines of a file" do

      io = build_string_IO

      call_API :files,
        :file_of_input_paths, fixture_file( :one_find ),
        :output_stream, io

      expect_succeeded

      io.string.should eql PRETTY_
    end

    it "from path (using find) with funky path" do

      io = build_string_IO

      call_API :files,
        :path, %w( not-there ),
        :output_stream, io

      expect_not_OK_event :find_error,
        'find: not-there: No such file or directory (exitstatus: 1)'

      expect_failed
    end

    it "from good path (using find) - pretty (well done)" do

      io = build_string_IO

      call_API :files,
        :path, [ fixture_tree( :one ) ],
        :output_stream, io

      _act = TestSupport_::Expect_line.shell( io.string ).excerpt( -4 .. -1 ).unindent

      _exp = <<-HERE.unindent
        └── one
            ├── foo.rb
            └── test
                └── foo_spec.rb
      HERE

      _act.should eql _exp
    end
  end
end
