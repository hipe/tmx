require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  ::Skylab::TestSupport::TestSupport[ TS_ = self ]

  if false  # #todo
  def self.apply_x_a_on_child_test_node x_a, child
    parent_anchor_module.apply_x_a_on_child_test_node x_a, child
  end
  end

  include Constants

  extend TestSupport_::Quickie

  TestLib_ = TestLib_

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

    def with_comment_block_in_ad_hoc_fake_file symbol
      _fake_file = fake_file_structure_for_path( big_file_path ).
        ad_hoc_fake_file( symbol )

      cb_stream = cb_stream_via_fake_file _fake_file
      @comment_block = cb_stream.gets
      x = cb_stream.gets
      x and fail "should only have one comment block: #{ x }"
      nil
    end

    def cb_stream_via_fake_file fake_file
      Subject_[].
        comment_block_stream_via_line_stream_using_single_line_comment_hack(
          fake_file.fake_open )
    end

    def fake_file_structure_for_path path
      CACHE__.fetch path do
        CACHE__[ path ] = Build_fake_file_structure_for_path[ path ]
      end
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

    def event_expression_agent
      TestSupport_::Lib_::Bzn_[]::API.expression_agent_instance
    end
  end

  CACHE__ = {}

  class Build_fake_file_structure_for_path

    class << self

      def [] path
        new( path ).build
      end
    end

    def initialize path
      @fake_files_hash_via_regex_h = {}
      @path = path
      @stay_rx = STAY_RX__
      @ad_hoc_code_blocks = {}
    end

    def build
      @fh = ::File.open @path, 'r'  # READ_MODE_
      @rx = %r(\A[ ]{4,}this is some code$)  # duplicates another, on purpose
      read_fake_file :file_one
      read_fake_file :file_two
      read_fake_file :file_three
      read_fake_file :file_four
      read_ad_hoc_code_block_one
      @fh.close
      flush
    end

    def read_ad_hoc_code_block_one
      @rx = %r(\A[[:space:]]*this example synthesizes every point\b)i
      advance_to_rx
      @fh.gets  # blank line
      @line = @fh.gets
      @stay_rx = /\A[[:space:]]+#/
      @ad_hoc_code_blocks[ :ad_hoc_one ] =
        build_fake_file_from_line_and_every_line_while_stay_rx
      nil
    end

    def read_fake_file name_symbol

      advance_to_rx

      _h = @fake_files_hash_via_regex_h.fetch @rx do
        @fake_files_hash_via_regex_h[ @rx ] = {}
      end

      _h[ name_symbol ] = build_fake_file_from_line_and_every_line_while_stay_rx

      nil
    end

    def advance_to_rx
      @line = @fh.gets
      begin
        @line or fail
        @rx =~ @line and break
        @line = @fh.gets
        redo
      end while nil
    end

    def build_fake_file_from_line_and_every_line_while_stay_rx
      fake_lines = []
      begin
        fake_lines.push @line
        @line = @fh.gets
        if @line && @stay_rx =~ @line
          redo
        end
      end while nil

      Fake_File__.new fake_lines
    end

    def flush
      Fake_File_Structure__.new @ad_hoc_code_blocks, @fake_files_hash_via_regex_h
    end

    STAY_RX__ = /\A[[:space:]]/

  end

  class Fake_File__

    def initialize a
      @a = a
    end

    def fake_open
      Callback_.stream.via_nonsparse_array @a
    end
  end

  class Fake_File_Structure__

    def initialize * a
      @ad_hoc_fake_file_h, @fake_files_hash_via_regex_h = a
    end

    def fake_files_demarcated_by_regex rx
      @fake_files_hash_via_regex_h.fetch rx
    end

    def ad_hoc_fake_file i
      @ad_hoc_fake_file_h.fetch i
    end
  end

  module Sandboxer
    define_singleton_method :spawn do
    end
  end

  Subject_ = -> do
    TestSupport_::DocTest
  end
end
