module Skylab::DocTest::TestSupport

  module Files

    def self.[] tcc
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
    end

    # -

  module Module_Methods___

    def with_big_file_path & p
      define_method :big_file_path_, & p
    end

    def with_magic_line _RX
      define_method :magic_line_regexp do
        _RX
      end
    end
  end

  module Instance_Methods___

    # -- setup

    def comment_block_via_ad_hoc_fake_file_symbol__ symbol
      _line_st = __line_stream_via_ad_hoc_fake_file_symbol symbol
      _block_st = block_stream_via_line_stream_ _line_st
      exactly_one_comment_block_via_block_stream_ _block_st
    end

    def maybe_some_code_then_exactly_one_comment_block_via_block_stream__ st

      o = st.gets
      if :static == o.category_symbol  # at least one item is assumed
        o = st.gets
      end
      o_ = st.gets
      if o_
        :static == o_.category_symbol or fail
      end
      _this_etc o, st
    end

    def exactly_one_comment_block_via_block_stream_ block_st
      o = block_st.gets
      o or fail _say_expected_comment_block
      _this_etc o, block_st
    end

    def _this_etc o, block_st
      _expect_is_comment o
      o_ = block_st.gets
      o_ and fail __say_expected_no_additional_block( o_ )
      o
    end

    def _expect_is_comment o
      :comment == o.category_symbol or fail __say_expected_comment_block_had( o )
    end

    def __say_expected_no_additional_block o
      "expected no additional block, had '#{ o.category_symbol }'"
    end

    def block_stream_via_line_stream_ line_st
      magnetics_module_::BlockStream_via_LineStream_and_Single_Line_Comment_Hack[ line_st ]
    end

    def with_file sym

      _st = line_stream_via_fake_file_symbol sym
      @_block_stream = block_stream_via_line_stream_ _st
      NIL_
    end

    def __line_stream_via_ad_hoc_fake_file_symbol sym

      _ffs = fake_file_structure_for_path big_file_path_
      _ff = _ffs.ad_hoc_fake_file sym
      _ff.fake_open
    end

    def line_stream_via_fake_file_symbol sym

      _ffs = fake_file_structure_for_path big_file_path_
      _ffh = _ffs.fake_files_demarcated_by_regex magic_line_regexp
      _ff = _ffh.fetch sym
      _ff.fake_open
    end

    # ~ produce paths

    h = {
      file_that_does_not_exist: :__noent_path,
      the_how_nodes_are_generated_document: :__this_one_path,  # 1x
      the_readme_document: :__readme_path,  # 2x
    }

    define_method :special_file_path_ do |sym|
      send h.fetch sym
    end

    def __noent_path
      TS_.noent_path_
    end

    def __readme_path
      ::File.join sidesystem_dir_path_, 'README.md'
    end

    def __this_one_path
      ::File.join sidesystem_dir_path_, 'doc/issues', THIS_ONE_FILENAME__
    end

    # ~

    def build_IO_spy_downstream_for_doctest

      _do_debug = method :do_debug

      _puts_map_proc = -> s do

        s_ = s.chomp

        if s_.length < s.length
          "dbg: «#{ s_ }»"
        else
          "dbg: «#{ s_ }[no newline]»"
        end
        # :+#guillemets
      end

      TestSupport_::IO.spy(
        :do_debug_proc, _do_debug,
        :debug_IO, debug_IO,
        :puts_map_proc, _puts_map_proc,
      )
    end

    cache = {}
    define_method :fake_file_structure_for_path do | path |
      cache.fetch path do
        x = Build_fake_file_structure_for_path___[ path ]
        cache[ path ] = x
        x
      end
    end

    def _Omni_Mock_
      Omni_Mock___
    end

    # --

    def expect_comment_block_with_number_of_lines exp_d
      _etc :comment, exp_d
    end

    def expect_static_block_with_number_of_lines exp_d
      _etc :static, exp_d
    end

    def _etc sym, exp_d
      o = @_block_stream.gets
      if o
        if sym == o.category_symbol
          if exp_d != o.number_of_lines___
            fail __say_N_for_M( o.number_of_lines___, exp_d, sym )
          end
        else
          o.category_symbol.should eql sym
        end
      else
        fail _say_expected_comment_block
      end
    end

    def __say_N_for_M n, m, sym
      "had #{ n }, needed #{ m } #{ sym } lines"
    end

    def __say_expected_comment_block_had o
      "expected comment block had '#{ o.category_symbol }' block"
    end

    def _say_expected_comment_block
      "expected comment block, had no block"
    end

    def expect_no_more_blocks

      o = @_block_stream.gets
      o and fail __say_this_fail o
    end

    def __say_this_fail o
      "expected no more comment blocks, had #{ o.category_symbol } block."
    end

    define_method :next_interesting_line_dedented, -> do
      rx = /\A[[:space:]]*/
      -> do
        ln = next_interesting_line
        ln and ln.gsub( rx, EMPTY_S_ )
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
      Home_::API
    end
  end

  # --

  README_FILENAME__ = 'README.md'
  THIS_ONE_FILENAME__ = '003-how-nodes-are-generated.md'

  # --

  class_via_path = {}
  Build_fake_file_structure_for_path___ = -> path do

    _cls = class_via_path.fetch ::File.basename path
    _cls[ path ]
  end

  Register__ = -> cls, path do
    class_via_path[ path ] = cls ; nil
  end

  Build_fake_file_structure__ = ::Class.new

  class Build_fake_files_in_README_file____ < Build_fake_file_structure__

    def work
      read_fake_file :file_one
      read_fake_file :file_two
      read_fake_file :file_three
      read_fake_file :file_four
      read_ad_hoc_code_block_one
      NIL_
    end

    def read_ad_hoc_code_block_one
      @rx = %r(\A[[:space:]]*this example synthesizes every point\b)i
      advance_to_next_rx
      skip_blank_lines
      @stay_rx = /\A[[:space:]]+#/
      @ad_hoc_code_blocks ||= {}
      @ad_hoc_code_blocks[ :ad_hoc_one ] =
        _build_fake_file_from_line_and_every_line_while_stay_rx
      NIL_
    end

    Register__[ self, README_FILENAME__ ]
  end

  class Build_fake_files_in_this_one_file____ < Build_fake_file_structure__

    def work
      _read_case_pair
      _read_case_pair
      _read_case_pair
      NIL_
    end

    Register__[ self, THIS_ONE_FILENAME__ ]
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
      fh = ::File.open @path, ::File::RDONLY
      @expect_line_scanner = TestSupport_::Expect_Line::Scanner.via_line_stream fh
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

      _h[ name_symbol ] = _build_fake_file_from_line_and_every_line_while_stay_rx

      nil
    end

    def _read_case_pair

      md = advance_to_next_rx CASE_INPUT_HEADER_RX__

      _example_name = md[ 1 ]

      skip_blank_lines

      _ff = _build_fake_file_from_line_and_every_line_while_stay_rx

      _md = advance_to_rx CASE_OUTPUT_HEADER_RX__

      _predicate_category = _md[ 1 ]

      skip_blank_lines

      _ff_ = _build_fake_file_from_line_and_every_line_while_stay_rx SPACEY_RX___

      kase = TS_::Case.new _example_name, _ff, _predicate_category, _ff_

      @case_h ||= {}
      @case_h[ kase.case_name_symbol ] = kase
    end

    CASE_INPUT_HEADER_RX__ = /\Ahere is (.+\bexample\b.*):$/i

    CASE_OUTPUT_HEADER_RX__ =
      /\A(?:so,? )?the above input generates(?: the(?: following)?)?(?: ([^\n:]+))?:?$/i

    SPACEY_RX___ = /\A[[:space:]]+[^[:space:]]/

    def advance_to_next_rx rx=@rx
      @expect_line_scanner.advance_to_next_rx rx
    end

    def advance_to_rx rx=@rx
      @expect_line_scanner.advance_to_rx rx
    end

    def skip_blank_lines
      @expect_line_scanner.skip_blank_lines
    end

    def _build_fake_file_from_line_and_every_line_while_stay_rx rx = @stay_rx
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

  class Omni_Mock___  # 1x
    def initialize x
      @x = x
    end
    attr_reader :x
    alias_method :a, :x
  end
# -
  end
end
