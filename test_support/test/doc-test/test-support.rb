require_relative '../test-support'

module Skylab::TestSupport::TestSupport::DocTest

  Top_TS_ = ::Skylab::TestSupport::TestSupport

  Top_TS_[ TS_ = self ]

  include Constants

  extend Home_::Quickie

  module ModuleMethods

    define_method :use, -> do

      cache_h = {}

      -> sym do

        ( cache_h.fetch sym do
          _const = Callback_::Name.via_variegated_symbol( sym ).as_const
          x = Bundles___.const_get _const, false
          cache_h[ sym ] = x
          x
        end )[ self ]
      end
    end.call

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

    def build_IO_spy_downstream_for_doctest

      Home_::IO.spy :do_debug_proc, -> do
        do_debug
      end, :debug_IO, debug_IO, :puts_map_proc, -> s do
        s_ = s.chomp

        if s_.length < s.length
          "dbg: «#{ s_ }»"
        else
          "dbg: «#{ s_ }[no newline]»"
        end
        # :+#guillemets
      end
    end

    def a_path_for_a_file_that_does_not_exist

      Top_TS_.noent_path_
    end

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
      CACHE___.fetch path do
        CACHE___[ path ] = Build_fake_file_structure_for_path[ path ]
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

    define_method :next_interesting_line_dedented, -> do
      rx = /\A[[:space:]]*/
      -> do
        ln = next_interesting_line
        ln and ln.gsub( rx, Home_::EMPTY_S_ )
      end
    end.call

    def next_interesting_line
      advance_to_next_rx @interesting_line_rx
      line
    end

    define_method :advance_to_module_line, -> do
      rx = %r(\Amodule )
      -> do
        advance_to_next_rx rx
      end
    end.call

    define_method :advance_to_describe_line, -> do
      rx = %r(\A[[:space:]]*describe )
      -> do
        advance_to_next_rx rx
      end
    end.call

    def subject_API
      Subject_[]::API
    end
  end

  Build_fake_file_structure_for_path = -> do

    rx = /\A\d+/

    -> path do
      const_get( :"Build_#{ rx.match( ::File.basename path )[ 0 ] }" )[ path ]
    end
  end.call

  Build_fake_file_structure__ = ::Class.new

  class Build_015 < Build_fake_file_structure__

    def work
      read_fake_file :file_one
      read_fake_file :file_two
      read_fake_file :file_three
      read_fake_file :file_four
      read_ad_hoc_code_block_one
      nil
    end

    def read_ad_hoc_code_block_one
      @rx = %r(\A[[:space:]]*this example synthesizes every point\b)i
      advance_to_next_rx
      skip_blank_lines
      @stay_rx = /\A[[:space:]]+#/
      @ad_hoc_code_blocks ||= {}
      @ad_hoc_code_blocks[ :ad_hoc_one ] =
        build_fake_file_from_line_and_every_line_while_stay_rx
      nil
    end
  end

  class Build_014 < Build_fake_file_structure__

    def work
      read_case_pair
      read_case_pair
      read_case_pair
      nil
    end
  end

  class Build_fake_file_structure__

    class << self

      def [] path
        new( path ).build
      end
    end  # >>

    def initialize path
      @ad_hoc_code_blocks = nil
      @case_h = nil
      @fake_files_hash_via_regex_h = nil
      @path = path
      @rx = %r(\A[ ]{4,}this is some code$)  # duplicates another, on purpose
      @stay_rx = STAY_RX__
    end

    def build
      fh = ::File.open @path, 'r'  # READ_MODE_
      @expect_line_scanner = Home_::Expect_Line::Scanner.via_line_stream fh
      work
      fh.close
      flush
    end

    def read_fake_file name_symbol

      advance_to_next_rx

      @fake_files_hash_via_regex_h ||= {}

      _h = @fake_files_hash_via_regex_h.fetch @rx do
        @fake_files_hash_via_regex_h[ @rx ] = {}
      end

      _h[ name_symbol ] = build_fake_file_from_line_and_every_line_while_stay_rx

      nil
    end

    def read_case_pair
      md = advance_to_next_rx CASE_INPUT_HEADER_RX__
      example_name = md[ 1 ]
      skip_blank_lines
      ff = build_fake_file_from_line_and_every_line_while_stay_rx

      md = advance_to_rx CASE_OUTPUT_HEADER_RX__

      predicate_category = md[ 1 ]
      skip_blank_lines
      ff_ = build_fake_file_from_line_and_every_line_while_stay_rx(
        /\A[[:space:]]+[^[:space:]]/ )

      @case_h ||= {}
      kase = TS_::Case_.new( example_name, ff, predicate_category, ff_ )
      @case_h[ kase.case_name_symbol ] = kase
    end

    CASE_INPUT_HEADER_RX__ = /\Ahere is (.+\bexample\b.*):$/i
    CASE_OUTPUT_HEADER_RX__ =
      /\A(?:so,? )?the above input generates(?: the(?: following)?)?(?: ([^\n:]+))?:?$/i

    def advance_to_next_rx rx=@rx
      @expect_line_scanner.advance_to_next_rx rx
    end

    def advance_to_rx rx=@rx
      @expect_line_scanner.advance_to_rx rx
    end

    def skip_blank_lines
      @expect_line_scanner.skip_blank_lines
    end

    def build_fake_file_from_line_and_every_line_while_stay_rx rx = @stay_rx
      @expect_line_scanner.build_fake_file_from_line_and_every_line_while_rx rx
    end

    def flush
      Fake_File_Structure__.new @ad_hoc_code_blocks, @case_h, @fake_files_hash_via_regex_h
    end

    STAY_RX__ = /\A[[:space:]]/

  end

  class Fake_File_Structure__

    def initialize * a
      @ad_hoc_fake_file_h, @case_h, @fake_files_hash_via_regex_h = a
    end

    def case i
      @case_h.fetch i
    end

    def fake_files_demarcated_by_regex rx
      @fake_files_hash_via_regex_h.fetch rx
    end

    def ad_hoc_fake_file i
      @ad_hoc_fake_file_h.fetch i
    end
  end

  class Omni_Mock_  # (used in 1 test)
    def initialize x
      @x = x
    end
    attr_reader :x
    alias_method :a, :x
  end

  Fixture_file_ = -> do

    p = -> filename do

      dirname = TS_.dir_pathname.join( 'fixture-files' ).to_path

      p = -> filename_ do
        ::File.join dirname, filename_
      end

      p[ filename ]
    end

    -> filename do
      p[ filename ]
    end
  end.call

  module Bundles___

    Expect_Event = -> tcc do
      Home_::Callback_.test_support::Expect_Event[ tcc ]
    end

    Expect_Line = -> tcc do
      Home_::Expect_line[ tcc ]
    end

    Memoizer_Methods = -> tcc do

      Home_::Memoization_and_subject_sharing[ tcc ]
    end
  end

  Subject_ = -> do
    Home_::DocTest
  end

  Home_ = Home_

  CACHE___ = {}
  Callback_ = Home_::Callback_
  DocTest_ = Home_::DocTest

end
