require_relative '../core'
require 'skylab/test-support/core'

module Skylab::TanMan::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  TanMan_ = ::Skylab::TanMan

  module TestLib_

    memoize = TanMan_::Callback_.memoize

    sidesys = TanMan_::Autoloader_.build_require_sidesystem_proc

    API_expect = -> ctx_cls do
      TanMan_::Brazen_::TestSupport::Expect_Event[ ctx_cls ]
    end

    CLI_client = -> x do
      HL__[]::CLI::Client[ x ]
    end

    CLI_pen_minimal = -> do
      HL__[]::CLI::Pen::Minimal.new
    end

    Class_creator_module_methods_module = -> mod do
      mod.include MetaHell__[]::Class::Creator::ModuleMethods ; nil
    end

    Constantize = -> x do
      TanMan_::Callback_::Name.lib.constantize[ x ]
    end

    Debug_IO = -> do
      HL__[]::System::IO.some_stderr_IO
    end

    Dev_client = -> do
      HL__[]::DEV::Client
    end

    Entity = -> do
      TanMan_::Brazen_::Entity
    end

    File_utils = memoize[ -> do
      require 'fileutils' ; ::FileUtils
    end ]

    FU_client = -> do
      HL__[]::IO::FU
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

    Shellwords = memoize[ -> do
      require 'shellwords' ; ::Shellwords
    end ]

    Three_IOs = -> do
      HL__[]::System::IO.some_three_IOs
    end

    Tmpdir = memoize[ -> do
      o = TanMan_::Lib_
      HL__[]::IO::Filesystem::Tmpdir.
        new o::Dev_tmpdir_pathname[].join( o::Tmpdir_stem[] ).to_path
    end ]

    TS__ = sidesys[ :TestSupport ]

    Unstyle_proc = -> do
      HL__[]::CLI::Pen::FUN.unstyle
    end

    Unstyle_styled = -> s do
      HL__[]::CLI::Pen::FUN.unstyle_styled[ s ]
    end
  end

  module CONSTANTS
    TanMan_ = TanMan_
    EMPTY_S_ = TanMan_::EMPTY_S_
    NEWLINE_ = "\n".freeze
    SPACE_ = TanMan_::SPACE_
    TestLib_ = TestLib_
    TestSupport_  = ::Skylab::TestSupport
  end

  include CONSTANTS # for use here, below

  TestSupport_ = TestSupport_

  # this is dodgy but should be ok as long as you accept that:
  # 1) you are assuming meta-attributes work and 2) the below is universe-wide!
  # 3) the below presents holes that need to be tested manually
  if false
  -> o do
    o.local_conf_dirname = 'local-conf.d' # a more visible name
    o.local_conf_maxdepth = 1
    o.local_conf_startpath = -> { TMPDIR }
    o.global_conf_path = -> { TMPDIR.join 'global-conf-file' }
  end.call TanMan_::API
  end

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

    def event_expression_agent
      self._OR_DO_YOU_WANT_THE_other_one
      TanMan_::API::EXPRESSION_AGENT__
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
      @parse = TS_::Parse.new do |parse|
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

    Debugging_event_receiver__ = -> do
      p = -> do
        x = Debugging_Event_Receiver__.new Some_debug_IO[], TS_::EXPRESSION_AGENT
        p = -> { x } ; x
      end
      -> { p[] }
    end.call

    class Debugging_Event_Receiver__
      def initialize *a
        @io, @expression_agent = a
      end
      def receive_event ev
        _y = ::Enumerator::Yielder.new do |s|
          @io.puts "(dbg: #{ s })"
        end
        ev.render_all_lines_into_under _y, @expression_agent
        if ev.has_tag :ok
          ev.ok
        end
      end
    end

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
  end
end
