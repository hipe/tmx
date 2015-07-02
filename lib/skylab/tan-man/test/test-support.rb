require_relative '../core'
require 'skylab/test-support/core'

module Skylab::TanMan::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  Home_ = ::Skylab::TanMan

  class << self

    def tmpdir_pathname_
      @tdpn ||= Home_.lib_.dev_tmpdir_pathname.join 'tm-testing'
    end
  end

  module TestLib_

    sidesys, stdlib = Home_::Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    define_singleton_method :_memoize, Home_::Callback_::Memoize

    Basic = sidesys[ :Basic ]

    Base_tmpdir__ = _memoize do
      Home_.lib_.system.filesystem.tmpdir(
        :path, TS_.tmpdir_pathname_.to_path,
        :max_mkdirs, 1 )
    end

    CLI_lib = -> do
      HL__[]::CLI
    end

    Constantize = -> x do
      Home_::Callback_::Name.lib.constantize[ x ]
    end

    Debug_IO = -> do
      System[].IO.some_stderr_IO
    end

    Dev_client = -> do
      HL__[]::DEV::Client
    end

    Empty_dir_pn = _memoize do
      Base_tmpdir__[].tmpdir_via_join 'empty-tmpdir', :max_mkdirs, 2
    end

    Entity = -> do
      Home_::Brazen_::Entity
    end

    File_utils = stdlib[ :FileUtils ]

    FUC = -> do
      System[].filesystem.file_utils_controller
    end

    HL__ = sidesys[ :Headless ]

    IO_adapter_spy = -> do
      HL__[]::TestSupport::IO_Adapter_Spy
    end

    JSON = stdlib[ :JSON ]

    PP = stdlib[ :PP ]

    String_lib = -> do
      Basic[]::String
    end

    Shellwords = stdlib[ :Shellwords ]

    System = -> do
      HL__[].system
    end

    Three_IOs = -> do
      HL__[].system.IO.some_three_IOs
    end

    TS__ = sidesys[ :TestSupport ]

    Volatile_tmpdir = _memoize do
      Base_tmpdir__[].tmpdir_via_join 'volatile-tmpdir', :max_mkdirs, 2
    end

    # ~

    EMPTY_S_ = Home_::EMPTY_S_

    DASH_ = '-'.freeze

    NEWLINE_ = Home_::NEWLINE_

    SPACE_ = Home_::SPACE_

    UNDERSCORE_ = Home_::UNDERSCORE_

  end

  module Constants
    Callback_ = Home_::Callback_
    Home_ = Home_
    TestLib_ = TestLib_
    TestSupport_  = ::Skylab::TestSupport
  end

  include Constants # for use here, below

  Callback_ = Callback_

  Expect_Event__ = Home_::Callback_.test_support::Expect_Event

  TestSupport_ = TestSupport_

  module ModuleMethods

    def using_grammar _GRAMMAR_PATHPART_ , *tags, & p

      context "using grammar #{ _GRAMMAR_PATHPART_ }", *tags do

        define_method :using_grammar do
          _GRAMMAR_PATHPART_
        end

        module_exec( & p )
      end
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

  end

  module InstanceMethods

    include Expect_Event__::Test_Context_Instance_Methods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      Some_debug_IO[]
    end

    def some_debug_IO
      Some_debug_IO[]
    end

    Some_debug_IO = -> do
      TestSupport_.debug_IO
    end

    def black_and_white_expression_agent_for_expect_event
      Home_::API::expression_agent_instance
    end

    # ~ grammar testing support

    def unparse_losslessly
      result.unparse.should eql some_input_string
    end

    def result
      @did_resolve_result ||= __resolve_result
      @result
    end

    def __resolve_result
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
      granule_s = using_grammar
      mod = grammars_module
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
      _underscore_separated_zero_padded_integer_segment_sequence =
        md[ :num ].gsub TestLib_::DASH_, TestLib_::UNDERSCORE_
      rest_s = md[ :rest ] and rest_s = "_#{ TestLib_::Constantize[ rest_s ] }"
      :"Grammar#{
        _underscore_separated_zero_padded_integer_segment_sequence }#{ rest_s }"
    end

    GRANULE_TO_CONST_RX__ = /\A(?<num>\d+(?:-\d+)*)(?:-(?<rest>.+))?\z/

    def __resolve_parse_session

      # life is easier if we don't have to ignore 'manually' the below event

      _oes_p = -> * i_a, & ev_p do

        case i_a.last
        when :using_parser_files, :creating
          NIL_
        else
          raise ev_p[].to_exception
        end
      end

      # but if you wanted to test for specific events here:
      # _oes_p = event_receiver_for_expect_event.handle_event_selectively

      @parse = TS_::Parse.new _oes_p do | o |
        o.generated_grammar_dir_path existent_testing_GGD_path
        o.root_for_relative_paths_for_load TS_.dir_pathname.to_path
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

        pn = TS_.tmpdir_pathname_.join 'grammerz'
        _PATH = pn.to_path

        if ! pn.exist?

          _tmpdir = Home_.lib_.system.filesystem.tmpdir :path, _PATH,
            :be_verbose, do_debug,
            :debug_IO, debug_IO,
            :max_mkdirs, 2

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
      module_with_subject_fixtures_node.dir_pathname.
        join( "fixtures/#{ input_file_granule }" ).to_path
    end

    def module_with_subject_fixtures_node
      @grammar_class
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

  end

  module Fixtures
    Callback_::Autoloader[ self ]

    module Dirs
      Callback_::Autoloader[ self ]
    end

    module Graphs
      class << self
        def [] sym
          dir_pathname.join(
            "#{ sym.id2name.gsub( Home_::UNDERSCORE_, Home_::DASH_ ) }.dot"
          ).to_path
        end
      end
      Callback_::Autoloader[ self ]
    end
  end

  NIL_ = nil
end
