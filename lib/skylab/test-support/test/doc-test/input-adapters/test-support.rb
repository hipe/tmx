require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest::Input

  ::Skylab::TestSupport::TestSupport::DocTest[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  TestSupport_ = TestSupport_
  Callback_ = TestSupport_::Callback_

  module ModuleMethods

    def with_big_file_path & p
      define_method :big_file_path, & p
    end

    def with_magic_line _RX
      define_method :magic_line_regexp do
        _RX
      end
    end
  end

  module InstanceMethods

    def with_file fake_file_name_symbol
      _fake_file = fake_file_structure[ fake_file_name_symbol ]
      @cb_stream = Subject_[].
        comment_block_stream_via_line_stream_using_single_line_comment_hack(
          _fake_file.fake_open )
      nil
    end

    def fake_file_structure
      Memoized_fake_files__[] ||
        Memoize_fake_files__[ big_file_path, magic_line_regexp ]
    end

    def expect_comment_block_with_number_of_lines exp_d
      cb = @cb_stream.gets
      if cb
        d = 0
        d += 1 while cb.gets
        if exp_d != d
          d.should eql exp_d
          fail
        end
      else
        fail "expected comment block, had none."
      end ; nil
    end

    def expect_no_more_comment_blocks
      cb = @cb_stream.gets
      if cb
        fail "expected no more comment blocks, had one."
      end
    end
  end

  -> do

    x = nil

    Memoized_fake_files__ = -> do
      x
    end

    Memoize_fake_files__ = -> path, first_rx do

      fh = ::File.open path, 'r'  # READ_MODE_

      stay_rx = /\A[[:space:]]/

      fake_files = []

      i_a = [ :file_one, :file_two, :file_three, :file_four ]
      4.times do

        line = fh.gets
        begin
          line or fail
          first_rx =~ line and break
          line = fh.gets
          redo
        end while nil

        fake_lines = []
        begin
          fake_lines.push line
          line = fh.gets
          if line && stay_rx =~ line
            redo
          end
        end while nil

        fake_files.push Fake_File__.new fake_lines
      end
      fh.close

      x = ::Hash[ i_a.zip fake_files ]
    end

  end.call

  class Fake_File__

    def initialize a
      @a = a
    end

    def fake_open
      Callback_.stream.via_nonsparse_array @a
    end
  end

  Subject_ = -> do
    TestSupport_::DocTest
  end
end
