require_relative '../core'
require 'skylab/test-support/core'

module Skylab::TanMan::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  TanMan_ = ::Skylab::TanMan

  class << self

    def tmpdir_pathname
      @tdpn ||= TanMan_.lib_.dev_tmpdir_pathname.join 'tm-testing'
    end
  end

  module TestLib_

    memoize = TanMan_::Callback_.memoize

    sidesys = TanMan_::Autoloader_.build_require_sidesystem_proc

    Bsc__ = sidesys[ :Basic ]

    Base_tmpdir__ = memoize[ -> do
      TanMan_.lib_.system.filesystem.tmpdir(
        :path, TS_.tmpdir_pathname.to_path,
        :max_mkdirs, 1 )
    end ]

    CLI_lib = -> do
      HL__[]::CLI
    end

    Class_creator_module_methods_module = -> mod do
      mod.include MetaHell__[]::Class::Creator::ModuleMethods ; nil
    end

    Constantize = -> x do
      TanMan_::Callback_::Name.lib.constantize[ x ]
    end

    Debug_IO = -> do
      System[].IO.some_stderr_IO
    end

    Dev_client = -> do
      HL__[]::DEV::Client
    end

    Empty_dir_pn = memoize[ -> do
      Base_tmpdir__[].tmpdir_via_join 'empty-tmpdir', :max_mkdirs, 2
    end ]

    Entity = -> do
      TanMan_::Brazen_::Entity
    end

    File_utils = memoize[ -> do
      require 'fileutils' ; ::FileUtils
    end ]

    FUC = -> do
      System[].filesystem.file_utils_controller
    end

    HL__ = sidesys[ :Headless ]

    IO_adapter_spy = -> do
      HL__[]::TestSupport::IO_Adapter_Spy
    end

    JSON = memoize[ -> do
      require 'json' ; ::JSON
    end ]

    Let = -> mod do
      mod.extend MetaHell__[]::Let
    end

    MetaHell__ = sidesys[ :MetaHell ]

    PP = memoize[ -> do
      require 'pp' ; ::PP
    end ]

    String_lib = -> do
      Bsc__[]::String
    end

    Shellwords = memoize[ -> do
      require 'shellwords' ; ::Shellwords
    end ]

    System = -> do
      HL__[].system
    end

    Three_IOs = -> do
      HL__[].system.IO.some_three_IOs
    end

    TS__ = sidesys[ :TestSupport ]

    Volatile_tmpdir = memoize[ -> do
      Base_tmpdir__[].tmpdir_via_join 'volatile-tmpdir', :max_mkdirs, 2
    end ]

    # ~

    EMPTY_S_ = TanMan_::EMPTY_S_

    DASH_ = '-'.freeze

    NEWLINE_ = TanMan_::NEWLINE_

    SPACE_ = TanMan_::SPACE_

    UNDERSCORE_ = '_'.freeze

  end

  module Constants
    Callback_ = TanMan_::Callback_
    TanMan_ = TanMan_
    TestLib_ = TestLib_
    TestSupport_  = ::Skylab::TestSupport
  end

  include Constants # for use here, below

  Callback_ = Callback_

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
  end

  module InstanceMethods

    include TanMan_::Callback_.test_support::Expect_Event::Test_Context_Instance_Methods

    def debug!
      @do_debug = true
    end

    attr_accessor :do_debug

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
      TanMan_::API::expression_agent_instance
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
        load _BASE_PN_.join( "client" ).to_path
        was_not_defined = true
      end
      @grammar_class = mod.const_get desired_module_const_i, false
      if was_not_defined
        @grammar_class.define_singleton_method :dir_pathname do
          _BASE_PN_
        end
      end ; nil
    end

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

      _oes_p = -> * i_a, & ev_p do

        if :info == i_a.first && :using == i_a[ 1 ]  # always ignore these, too noisy
          if do_debug
            ev = ev_p[]
            debug_IO.puts "(ignoring #{ i_a.inspect } event: #{ black_and_white( ev ).inspect })" ; nil
          end
        else
          ev = ev_p[]
          event_receiver_for_expect_event.receive_ev ev
          ev.ok
        end
      end

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

        pn = TS_.tmpdir_pathname.join 'grammerz'
        _PATH = pn.to_path

        if ! pn.exist?

          _tmpdir = TanMan_.lib_.system.filesystem.tmpdir :path, _PATH,
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
      input_file_pathname.to_path
    end

    def input_file_pathname
      @input_file_pathname ||= build_input_file_pathname
    end

    def build_input_file_pathname
      module_with_subject_fixtures_node.dir_pathname.
        join "fixtures/#{ input_file_granule }"
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
      x_a.push :input_path, input_file_pathname.to_path ; nil
    end

    def add_input_arguments_to_iambic_when_input_string x_a
      x_a.push :input_string, input_string ; nil
    end

    def some_input_string
      send :"some_input_string_when_#{ input_mechanism_i }"
    end

    def some_input_string_when_input_file_granule
      @input_file_pathname.read
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
      TanMan_::API
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
  end
end
