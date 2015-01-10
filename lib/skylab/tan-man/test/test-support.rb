require_relative '../core'
require 'skylab/test-support/core'

module Skylab::TanMan::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  TanMan_ = ::Skylab::TanMan

  class << self

    def tmpdir_pathname
      @tdpn ||= TanMan_.lib_.system.defaults.dev_tmpdir_pathname.join 'tm-testing'
    end
  end

  module TestLib_

    memoize = TanMan_::Callback_.memoize

    sidesys = TanMan_::Autoloader_.build_require_sidesystem_proc

    API_expect = -> ctx_cls do
      TanMan_::Callback_.test_support::Expect_Event[ ctx_cls ]
    end

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
      Base_tmpdir__[].tmpdir_via_join( 'empty-tmpdir' ).
        with :max_mkdirs, 2
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
      Base_tmpdir__[].tmpdir_via_join( 'volatile-tmpdir' ).with(
        :max_mkdirs, 2 )
    end ]
  end

  module Constants
    Callback_ = TanMan_::Callback_
    TanMan_ = TanMan_
    EMPTY_S_ = TanMan_::EMPTY_S_
    NEWLINE_ = TanMan_::NEWLINE_
    SPACE_ = TanMan_::SPACE_
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

    def using_input _STEM_, *tags, & p

      context "using input #{ _STEM_ }", *tags do

        define_method :input_mechanism_i do
          :input_file_granule
        end

        define_method :input_file_granule do
          _STEM_
        end

        module_exec( & p )
      end
    end

    def using_input_string _STR_, *tags, & p

      desc = if tags.first.respond_to? :ascii_only?
        tags.shift
      else
        "using input string #{ _STR_.inspect }"
      end

      context desc, * tags do

        input _STR_

        module_exec( & p )
      end
    end

    def input _STR_

      define_method :input_mechanism_i do
        :input_string
      end

      define_method :input_string do
        _STR_
      end
    end
  end

  module InstanceMethods

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

    def result
      @did_resolve_result ||= resolve_result
      @result
    end

    def resolve_result
      @result = produce_result
      true
    end

    def produce_result
      @did_prepare_to_produce_result ||= prepare_to_produce_result
      produce_result_via_perform_parse
    end

    def prepare_to_produce_result
      resolve_grammar_class
      resolve_parse
      true
    end

    def resolve_grammar_class
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
        md[ :num ].gsub DASH_, UNDERSCORE_
      rest_s = md[ :rest ] and rest_s = "_#{ TestLib_::Constantize[ rest_s ] }"
      :"Grammar#{
        _underscore_separated_zero_padded_integer_segment_sequence }#{ rest_s }"
    end

    DASH_ = '-'.freeze ; UNDERSCORE_ = '_'.freeze

    GRANULE_TO_CONST_RX__ = /\A(?<num>\d+(?:-\d+)*)(?:-(?<rest>.+))?\z/

    def resolve_parse

      _path = existent_testing_GGD_path

      @parse = TS_::Parse.new do |parse|
        parse.generated_grammar_dir_path _path
        parse.subscribe( & method( :subscribe_to_parse_events ) )
        parse.set_root_for_relative_paths_for_load TS_.dir_pathname
        _rel_pn = @grammar_class.dir_pathname.relative_path_from TS_.dir_pathname
        parse.add_grammar_path _rel_pn.join( ALWAYS_G1__ ).to_path
      end
    end
    ALWAYS_G1__ = 'g1.treetop'.freeze

    def subscribe_to_parse_events o
      o.delegate_to debugging_event_receiver
      o.subscribe_to_parser_loading_error_event
      o.subscribe_to_parser_error_event
      if do_debug
        o.subscribe_to_parser_loading_info_event
      else
        o.on_parser_loading_info_event do |ev|
          # because #open [#ttt-004]
        end
      end ; nil
    end

    def debugging_event_receiver
      Debugging_event_receiver__[]
    end

    Debugging_event_receiver__ = Callback_.memoize do
      Debugging_Event_Receiver__.new Some_debug_IO[], TS_::EXPRESSION_AGENT
    end

    class Debugging_Event_Receiver__
      def initialize *a
        @io, @expression_agent = a
      end
      def receive_event ev
        y = ::Enumerator::Yielder.new do |s|
          @io.puts "(dbg: #{ s })"
        end
        if ::String === ev
          y << "(WAS STRING: #{ ev })"
        else
          ev.render_all_lines_into_under y, @expression_agent
          if ev.has_tag :ok
            ev.ok
          end
        end
      end
    end

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
      @parse.parse_file input_file_pathname
    end

    def via_parse_via_input_string_produce_result
      @parse.parse_string input_string
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
      x_a.push :input_pathname, input_file_pathname ; nil
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
end
