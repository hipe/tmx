require 'skylab/tan_man'
require 'skylab/test_support'

module Skylab::TanMan::TestSupport

  class << self

    def [] tcc
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
    end

    def client_proximity_index_
      @___cpi ||= ___build_CPI
    end

    def ___build_CPI

      _ = Home_.sidesystem_path_

      TS_::Proximity_Index_.new _, 'client', 'test', TS_
    end

    cache = {}
    define_method :lib_ do | sym |
      cache.fetch sym do
        x = TestSupport_.fancy_lookup sym, TS_
        cache[ sym ] = x
        x
      end
    end

    def tmpdir_path_
      @___tmpdir_path ||= __build_tmpdir_path
    end

    def __build_tmpdir_path
      ::File.join(
        Home_.lib_.dev_tmpdir_path,
        'tm-testing-cache',
      )
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  TestSupport_::Quickie.enable_kernel_describe

  Expect_Event__ = Callback_.test_support::Expect_Event

  module Module_Methods___

    def use sym
      TS_.lib_( sym )[ self ]
    end

    def using_input stem, *tags, & p

      context "using input #{ stem }", *tags do

        against_file stem

        module_exec( & p )
      end
    end

    def using_input_string _STR_, *tags, & p

      _desc = if tags.first.respond_to? :ascii_only?
        tags.shift
      else
        "using input string #{ _STR_.inspect }"
      end

      context _desc, * tags do

        against_string _STR_

        module_exec( & p )
      end
    end

    def against_file _RELPATH_

      define_method :input_mechanism_i do
        :input_file_granule
      end

      define_method :input_file_granule do
        _RELPATH_
      end

      nil
    end

    def against_string _STR_

      define_method :input_mechanism_i do
        :input_string
      end

      define_method :input_string do
        _STR_
      end

      nil
    end

    define_method :ignore_these_events, Expect_Event__::IGNORE_THESE_EVENTS_METHOD

    def shared_subject sym, & p
      x = nil ; yes = true
      define_method sym do
        if yes
          yes = false
          x = instance_exec( & p )
        end
        x
      end
    end

    alias_method :dangerous_memoize, :shared_subject

    def memoize sym, & p
      x = nil ; yes = true
      define_method sym do
        if yes
          yes = false
          x = p[]
        end
        x
      end
    end
  end

  module Instance_Methods___

    include Expect_Event__::Test_Context_Instance_Methods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def _same
      TestSupport_.debug_IO
    end

    alias_method :debug_IO, :_same

    alias_method :some_debug_IO, :_same

    def handle_event_selectively_
      event_log.handle_event_selectively
    end

    def black_and_white_expression_agent_for_expect_event
      Home_::API::expression_agent_instance
    end

    # -- ..

    def expect_committed_changes_

      _em = expect_OK_event :success

      ev = _em.cached_event_value

      _sym = ev.to_event.terminal_channel_symbol

      :collection_resource_committed_changes == _sym or fail

      ev
    end

    # ~ grammar testing support

    def unparse_losslessly
      result.unparse.should eql some_input_string
    end

    def result
      @did_resolve_result ||= ___resolve_result
      @result
    end

    def ___resolve_result
      @result = produce_result
      true
    end

    def produce_result
      @did_prepare_to_produce_result ||= prepare_to_produce_result
      produce_result_via_perform_parse
    end

    def prepare_to_produce_result
      __resolve_grammar_class
      __resolve_parse_session
      true
    end

    def __resolve_grammar_class
      granule_s = grammar_pathpart_
      mod = grammars_module_
      desired_module_const_i = bld_grammar_const granule_s
      if ! mod.const_defined? desired_module_const_i
        _BASE_PN_ = mod.dir_pathname.join granule_s
        load _BASE_PN_.join( CLIENT___ ).to_path
        was_not_defined = true
      end
      @grammar_class = mod.const_get desired_module_const_i, false
      if was_not_defined
        @grammar_class.define_singleton_method :dir_pathname do
          _BASE_PN_
        end
      end ; nil
    end

    CLIENT___ = 'client'

    def bld_grammar_const granule_s

      md = GRANULE_TO_CONST_RX__.match granule_s

      _number_part = md[ :num ].gsub DASH_, UNDERSCORE_

      rest_s = md[ :rest ]
      if rest_s
        rest_s = "_#{ Callback_::Name::Conversion_Functions::Constantize[ rest_s ] }"
      end

      :"Grammar#{ _number_part }#{ rest_s }"
    end

    GRANULE_TO_CONST_RX__ = /\A(?<num>\d+(?:-\d+)*)(?:-(?<rest>.+))?\z/

    def __resolve_parse_session

      # life is easier if we don't have to ignore 'manually' the below event

      _oes_p = -> * i_a, & ev_p do

        case i_a.last
        when :using_parser_files, :creating, :mkdir_p
          NIL_
        else
          raise ev_p[].to_exception
        end
      end

      # but if you wanted to test for specific events here:
      # _oes_p = handle_event_selectively_

      @parse = TS_::Parse.new _oes_p do | o |

        o.root_for_relative_paths_for_load TS_.dir_pathname.to_path

        o.generated_grammar_dir_path existent_testing_GGD_path

        o.grammar_path @grammar_class.dir_pathname.relative_path_from( TS_.dir_pathname ).join( ALWAYS_G1__ ).to_path
      end

      nil
    end

    ALWAYS_G1__ = 'g1.treetop'.freeze

    def existent_testing_GGD_path
      path = Memoized_GGD_path__[]
      path || Memoize_GGD_path__[ do_debug, debug_IO ]
    end

    -> do

      _PATH = nil

      Memoized_GGD_path__ = -> { _PATH }

      Memoize_GGD_path__ = -> do_debug, debug_IO do

        _PATH = ::File.join TS_.tmpdir_path_, 'grammerz'

        if ! ::File.exist? _PATH

          _tmpdir = Home_.lib_.system.filesystem.tmpdir :path, _PATH,
            :be_verbose, do_debug,
            :debug_IO, debug_IO,
            :max_mkdirs, 3  # you can make __tmx__, you can make [tm], and this

          _tmpdir.prepare_when_not_exist
        end

        _PATH
      end
    end.call

    # ~ near input mechanism reification

    def produce_result_via_perform_parse
      send produce_result_via_parse_method_i
    end

    def via_parse_via_input_file_granule_produce_result
      @parse.parse_file input_file_path
    end

    def via_parse_via_input_string_produce_result
      @parse.parse_string input_string
    end

    def input_file_path
      @input_file_path ||= build_input_file_path
    end

    def build_input_file_path

      _head = fixtures_path_

      _tail = input_file_granule

      ::File.join _head, _tail
    end

    def fixtures_path_
      ::File.join @grammar_path.dir_pathname.to_path, FIXTURES_ENTRY_
    end

    def produce_result_via_parse_method_i
      :"via_parse_via_#{ input_mechanism_i }_produce_result"
    end

    def add_input_arguments_to_iambic x_a
      send :"add_input_arguments_to_iambic_when_#{ input_mechanism_i }", x_a
    end

    def add_input_arguments_to_iambic_when_input_file_granule x_a
      x_a.push :input_path, input_file_path; nil
    end

    def add_input_arguments_to_iambic_when_input_string x_a
      x_a.push :input_string, input_string ; nil
    end

    def some_input_string
      send :"some_input_string_when_#{ input_mechanism_i }"
    end

    def some_input_string_when_input_file_granule
      ::File.read @input_file_path
    end

    def some_input_string_when_input_string
      input_string
    end

    def add_output_arguments_to_iambic x_a
      @output_s = ::String.new
      x_a.push :output_string, @output_s ; nil
    end

    # ~ hook-outs to ancillary API's

    def subject_API
      Home_::API
    end

    # ~ misc business

    def cfn
      CONFIG_FILENAME_THAT_IS_NOT_A_DOTFILE_FOR_VISIBILITY__
    end

    def cdn
      CONFIG_DIRNAME_THAT_IS_NOT_A_DOTFILE_FOR_VISIBILITY__
    end


    CONFIG_DIRNAME_THAT_IS_NOT_A_DOTFILE_FOR_VISIBILITY__ = 'local-conf.d'.freeze
    CONFIG_FILENAME_THAT_IS_NOT_A_DOTFILE_FOR_VISIBILITY__ = "#{
      CONFIG_DIRNAME_THAT_IS_NOT_A_DOTFILE_FOR_VISIBILITY__ }/conf.conf".freeze


    # ~ fs

    def read_file_ path
      ::File.open( path, ::File::RDONLY ).read
    end
  end

  Expect_Line = -> tcc do
    TestSupport_::Expect_line[ tcc ]
  end

  Autoloader_ = Callback_::Autoloader

  module Fixtures
    Autoloader_[ self ]

    module Dirs
      Autoloader_[ self ]
    end

    module Graphs
      class << self
        def [] sym
          dir_pathname.join(
            "#{ sym.id2name.gsub( UNDERSCORE_, DASH_ ) }.dot"
          ).to_path
        end
      end
      Autoloader_[ self ]
    end
  end

  module TestLib_

    stdlib, = Autoloader_.at(
      :build_require_stdlib_proc,
    )

    define_singleton_method :_memoize, Callback_::Memoize

    base_tmpdir = _memoize do
      Home_.lib_.system.filesystem.tmpdir(
        :path, TS_.tmpdir_path_,
        :max_mkdirs, 1 )
    end

    Empty_dir_pn = _memoize do
      base_tmpdir[].tmpdir_via_join 'empty-tmpdir', :max_mkdirs, 2
    end

    PP = stdlib[ :PP ]

    Volatile_tmpdir = _memoize do
      base_tmpdir[].tmpdir_via_join 'volatile-tmpdir', :max_mkdirs, 2
    end
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Home_ = ::Skylab::TanMan

  ACHIEVED_ = true
  COMMON_MISS_ = :missing_required_attributes
  DASH_ = Home_::DASH_
  EMPTY_A_ = Home_::EMPTY_A_
  EMPTY_S_ = Home_::EMPTY_S_
  IDENTITY_= -> x { x }
  FIXTURES_ENTRY_ = 'fixtures'
  NEWLINE_ = Home_::NEWLINE_
  NIL_ = nil
  SPACE_ = Home_::SPACE_
  TS_ = self
  UNDERSCORE_ = Home_::UNDERSCORE_

end
