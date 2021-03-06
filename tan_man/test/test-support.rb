require 'skylab/tan_man'
require 'skylab/test_support'

module Skylab::TanMan::TestSupport

  class << self

    def [] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end

    def client_proximity_index_
      @___cpi ||= ___build_CPI
    end

    def ___build_CPI

      _ = Home_.sidesystem_path_

      TS_::ProximityIndex_.new _, 'client', 'test', TS_
    end

    cache = {}
    define_method :lib_ do | sym |
      cache.fetch sym do
        x = TestSupport_.fancy_lookup sym, TS_  # these are #here2
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

  Common_ = ::Skylab::Common

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  TestSupport_::Quickie.enable_kernel_describe

  module ModuleMethods___

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

    def IGNORE_METHOD__
      NOTHING_
    end

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

  module InstanceMethods___

    # include Want_Event__::Test_Context_Instance_Methods  # #todo

    # -- expectations

    def want_committed_changes_

      _em = want_OK_event :success

      ev = _em.cached_event_value

      _sym = ev.to_event.terminal_channel_symbol

      :collection_resource_committed_changes == _sym or fail

      ev
    end

    def see_unexpected_emission em  # ..

      if em.emission_looks_like_expression  # ..
        if ! do_debug
          _cha_cha_TS em, :express_into_under_debuggingly
        end
      else
        _cha_cha_TS em.emission_proc[], :express_into_under
      end
      NIL
    end

    def _cha_cha_TS o, m  # ..
      io = debug_IO
      io.puts "(MESSAGE FROM EMISSION:"
      _y = ::Enumerator::Yielder.new { |s| io.puts "  #{ s }" }
      _expag = black_and_white_expression_agent_for_want_emission
      o.send m, _y, _expag
      io.puts "<-THAT)"
      NIL
    end

    def want_these_lines_in_array_with_trailing_newlines_ a, & p
      TestSupport_::Want_Line::Want_these_lines_in_array_with_trailing_newlines.call(
        a, p, self )
    end

    def want_these_lines_in_array_ a, & p
      TestSupport_::Want_these_lines_in_array[ a, p, self ]
    end

    def expression_agent_for_CLI_TM
      Home_::CLI::InterfaceExpressionAgent___.instance
    end

    def black_and_white_expression_agent_for_want_emission
      Home_::API::expression_agent_instance
    end

    # -- (microscopic stowaway)

    def the_subject_action_for_hear_
      [ :hear, :hear ]
    end

    # -- grammar testing support

    def unparse_losslessly
      expect( result.unparse ).to eql some_input_string
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
      const = __build_grammar_const granule_s

      if ! mod.const_defined? const, false
        was_not_defined = true
        _BASE_PATH_ = ::File.join mod.dir_path, granule_s
        _load_path = ::File.join _BASE_PATH_, CLIENT___
        load _load_path
      end

      @grammar_class = mod.const_get const, false
      if was_not_defined
        @grammar_class.define_singleton_method :dir_path do
          _BASE_PATH_
        end
      end ; nil
    end

    CLIENT___ = 'client'

    def __build_grammar_const granule_s

      md = GRANULE_TO_CONST_RX__.match granule_s

      _number_part = md[ :num ].gsub DASH_, UNDERSCORE_

      rest_s = md[ :rest ]
      if rest_s
        rest_s = "_#{ Common_::Name::ConversionFunctions::Constantize[ rest_s ] }"
      end

      :"Grammar#{ _number_part }#{ rest_s }"
    end

    GRANULE_TO_CONST_RX__ = /\A(?<num>\d+(?:-\d+)*)(?:-(?<rest>.+))?\z/

    def __resolve_parse_session

      # life is easier if we don't have to ignore 'manually' the below event

      _p = -> * sym_a, & ev_p do

        case sym_a.last
        when :using_parser_files, :creating, :mkdir_p
          NIL_
        else
          raise ev_p[].to_exception
        end
      end

      # but if you wanted to test for specific events here:
      # _p = listener_

      _head = Localize_grammar_path___[ @grammar_class.dir_path ]
      _path = ::File.join _head, ALWAYS_G1__

      @parse = TS_::Parse.new _p do |o|

        o.root_for_relative_paths_for_load TS_.dir_path  # same as #here

        o.generated_grammar_dir_path existent_testing_GGD_path

        o.grammar_path _path
      end

      NIL
    end

    ALWAYS_G1__ = 'g1.treetop'.freeze

    Localize_grammar_path___ = -> do

      p = -> path do
        p = Home_::Path_lib_[]::Localizer[ TS_.dir_path ]  # #here
        p[ path ]
      end

      -> path do
        p[ path ]
      end
    end.call

    def existent_testing_GGD_path
      path = Memoized_GGD_path__[]
      path || Memoize_GGD_path__[ do_debug, debug_IO ]
    end

    -> do

      path = nil

      Memoized_GGD_path__ = -> { path }

      Memoize_GGD_path__ = -> do_debug, debug_IO do

        path = ::File.join TS_.tmpdir_path_, 'grammerz'

        if ! ::File.exist? path

          _tmpdir = Home_.lib_.system_lib::Filesystem::Tmpdir.with(
            :path, path,
            :be_verbose, do_debug,
            :debug_IO, debug_IO,
            :max_mkdirs, 3,  # you can make __tmx__, you can make [tm], and this
          )

          _tmpdir.prepare_when_not_exist
        end

        path
      end
    end.call

    # -- near input mechanism reification

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

    # -- hook-outs to ancillary API's

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_  # related to #here3
    end

    def prepare_subject_API_invocation invo
      invo
    end

    def subject_API_value_of_failure
      FALSE
    end

    def subject_API
      Home_::API
    end

    # -- misc business

    def cfn
      CONFIG_FILENAME_THAT_IS_NOT_A_DOTFILE_FOR_VISIBILITY__
    end

    def cdn
      CONFIG_DIRNAME_THAT_IS_NOT_A_DOTFILE_FOR_VISIBILITY__
    end

    CONFIG_DIRNAME_THAT_IS_NOT_A_DOTFILE_FOR_VISIBILITY__ = 'local-conf.d'.freeze
    CONFIG_FILENAME_THAT_IS_NOT_A_DOTFILE_FOR_VISIBILITY__ = "#{
      CONFIG_DIRNAME_THAT_IS_NOT_A_DOTFILE_FOR_VISIBILITY__ }/conf.conf".freeze

    # --

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    # -- fs

    def read_file_ path
      ::File.open( path, ::File::RDONLY ).read
    end
  end

  # ==

  FixtureGraphs = -> do  # (here as if it is a module..)
    p = -> sym0 do
      dir_path = ::File.join TS_.dir_path, 'fixture-graphs'
      p = -> sym do
        _tail = "#{ sym.id2name.gsub( UNDERSCORE_, DASH_ ) }.dot"
        ::File.join dir_path, _tail
      end
      p[ sym0 ]
    end
    -> sym do
      p[ sym ]
    end
  end.call

  # == :#here2

  Want_CLI_Or_API = -> tcc do
    Home_::Zerk_lib_[].test_support::Want_CLI_or_API[ tcc ]
    tcc.send :alias_method, :call_API, :call  # legacy
  end

  Want_Line = -> tcc do
    TestSupport_::Want_line[ tcc ]
  end

  Want_Emission_Classic = -> tcc do
    Common_.test_support::Want_Emission[ tcc ] # #here3
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  The_Method_Called_Let = -> tcc do
    TestSupport_::Let[ tcc ]
  end

  # ==

  Autoloader_ = Common_::Autoloader
  Lazy_ = Common_::Lazy

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Home_ = ::Skylab::TanMan

  ACHIEVED_ = true
  Byte_upstream_reference_ = Home_::Byte_upstream_reference_
  COMMON_MISS_ = :missing_required_attributes
  DASH_ = Home_::DASH_
  EMPTY_A_ = Home_::EMPTY_A_
  EMPTY_S_ = Home_::EMPTY_S_
  FIXTURES_ENTRY_ = 'fixtures'
  NEWLINE_ = Home_::NEWLINE_
  NIL_ = nil
  NIL = nil  # #open [#sli-116.C]
  NOTHING_ = nil
  SPACE_ = Home_::SPACE_
  TS_ = self
  UNDERSCORE_ = Home_::UNDERSCORE_
end
