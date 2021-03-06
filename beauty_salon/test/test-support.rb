# frozen_string_literal: true

require 'skylab/beauty_salon'
require 'skylab/test_support'

module Skylab::BeautySalon::TestSupport

  class << self
    def [] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  module ModuleMethods___

    def use sym
      lib( sym )[ self ]
    end

    -> do
      h = {}
      define_method :lib, ( -> sym do
        x = TestSupport_.fancy_lookup sym, TS_
        h[ sym ] = x
        x
      end )
    end.call
  end

  module InstanceMethods___

    def want_exception_with_this_symbol_ sym
      begin
        yield
      rescue Home_::MyException_ => e
      end
      e || fail
      e.symbol == sym || fail
    end

    def want_these_lines_in_array_with_trailing_newlines_ a, & p
      TestSupport_::Want_Line::
          Want_these_lines_in_array_with_trailing_newlines[ a, p, self ]
    end

    def want_these_lines_in_array_ a, & p
      TestSupport_::Want_these_lines_in_array[ a, p, self ]
    end

    def fixture_functions_ tail
      Fixture_function_path__[ tail ]
    end

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end

    define_method :get_invocation_strings_for_want_stdout_stderr, -> do

      a = %w( zippo ).freeze
      -> do
        a
      end
    end.call

    def subject_API_value_of_failure
      FALSE
    end

    def subject_API
      Home_::API
    end

    def main_magnetics_
      Home_::CrazyTownMagnetics_
    end

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    # -- retrofit

    def want_not_OK_event_ sym
      em = want_not_OK_event
      expect( em.cached_event_value.to_event.terminal_channel_symbol ).to eql sym
      em
    end

    def want_OK_event_ sym=nil, msg=nil

      em = want_OK_event nil, msg
      if sym
        expect( em.cached_event_value.to_event.terminal_channel_symbol ).to eql sym
      end
      em
    end
  end

  Home_ = ::Skylab::BeautySalon
  Lazy_ = Home_::Lazy_

  # -- bundles

  module My_API

    def self.[] tcc
      Memoizer_Methods[ tcc ]
      Want_Emission_Fail_Early[ tcc ]
      tcc.include self
    end

    def want_API_result_for_failure_
      want_result nil
    end

    def want_API_result_for_success_  # track this idea
      want_result nil
    end

    def expression_agent
      Expression_agent_preferred_[]
    end

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    def subject_API
      Home_::API
    end
  end

  module Modality_Agnostic_Interface_Things

    def self.[] tcc ; tcc.include self end

    def my_oxford_and_ lemma_s, anything=nil, these

      buffer = ::String.new

      if 1 == these.length
        buffer << lemma_s
      else
        buffer << lemma_s.sub( %r(y\z), 'ie' )
        buffer << 's'  # egads
      end
      anything and buffer << anything
      buffer << Common_::Oxford_and[ these ]
    end

    define_method :all_toplevel_actions_normal_symbols_, ( Lazy_.call do
      [
        :ping,
        :crazy_town,
        :deliterate,
        :text,
      ].freeze
    end )
  end

  module My_Reports

    def self.[] tcc
      tcc.include self
    end

    def call_report_ p, report_slug
      if instance_variable_defined? :@EMISSION_SPY
        spy = remove_instance_variable :@EMISSION_SPY
      end
      if spy
        __call_report_with_expectations_MR spy, p, report_slug
      else
        _call_report_coldly_MR p, report_slug
      end
    end

    def __call_report_with_expectations_MR spy, p, report_slug

      spy.call_by do
        _use_p = -> o do
          p[ o ]
          o.listener = spy.listener
        end
        _call_report_coldly_MR _use_p, report_slug
      end
      spy.execute_under self
    end

    def _call_report_coldly_MR p, report_slug

      a, pp = Iambic_via_Definition___.call_by do |o|
        o.report_name = report_slug
        p[ o ]
        o.listener ||= -> * chan, & em_p do  # :#here1
          self.DIE_ON_UNEXPECTED_EMISSION em_p, chan
        end
      end
      Home_::API.invocation_via_argument_array( a, & pp ).execute
    end

    def anticipate_ * chan, & msg
      _spy = ( @EMISSION_SPY ||= begin
        Common_.test_support::Want_Emission_Fail_Early::Spy.new
      end )
      _spy.want_emission msg, chan ; nil
    end

    def anticipate_no_emissions_
      @EMISSION_SPY = nil
    end

    def DIE_ON_UNEXPECTED_EMISSION em_p, chan
      if :info == chan[0] && :expression == chan[1]
        # if we're not capturing any emssions at all,
        # let `info` slide by without freaking out
        NOTHING_  # hi.
      else
        __do_die_yadda_MR em_p, chan
      end
    end

    def __do_die_yadda_MR em_p, chan

      io = debug_IO
      io.puts "GONNA DIE: #{ chan.inspect }"
      y = ::Enumerator::Yielder.new do |line|
        io.puts "YERP: #{ line }"
      end
      em_p[ y ]
      exit 0
    end
  end

  class Iambic_via_Definition___ < Home_::Common_::MagneticBySimpleModel

    # the initial take of these tests happened when the reports were
    # implemented as plain old magnetics behind an ad-hoc feature branch-
    # ish behind a legacy framework. now reports are implemented behind the
    # current toolkits with a formal feature branch (but they are still
    # plain old magnetics). :[#007.C]
    # SO the subject exposes an interface that *was* geared towards calling
    # one of the frontmost magnetics that called the report magnets. now
    # it is a facade that just calls the plain old API. (there's such a
    # nuanced pipeline that it's not recommended that you try to call these
    # report magnets by hand.)

    def initialize
      @_pairs = []
      super
    end

    def macro_string= s
      s || no
      @_pairs.push [ :macro, s ]
    end

    def replacement_function_string= s
      s || no
      @_pairs.push [ :replacement_function, s ]  # look
    end

    def code_selector_string= s
      s || no
      @_pairs.push [ :code_selector, s ]  # look
    end

    def files_file= s
      s || no
      @_pairs.push [ :files_file, s ] ; nil
    end

    def argument_paths= paths
      paths.each do |path|
        @_pairs.push [ :file, path ]
      end
    end

    attr_writer(
      :listener,
      :report_name,
    )
    attr_reader(
      :listener,  # #here1
    )

    def execute
      a = [ :crazy_town ]
      a.push remove_instance_variable :@report_name
      remove_instance_variable( :@_pairs ).each do |k, x|
        a.push k, x
      end
      _li = remove_instance_variable :@listener
      instance_variables.length.nonzero? && fail
      [ a, _li ]
    end
  end

  Want_Event = -> tcc do
    Common_.test_support::Want_Emission[ tcc ]
  end

  Want_Emission_Fail_Early = -> tcc do
    Common_.test_support::Want_Emission_Fail_Early[ tcc ]
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  Non_Interactive_CLI = -> tcc do
    Zerk_test_support_[]::Non_Interactive_CLI[ tcc ]
  end

  # --

  def self._MY_BIN_PATH
    @___mbp ||= ::File.expand_path( '../../bin', __FILE__ )
  end

  # --

  Stem_via_filesystem_path_ = -> path do
    bn = ::File.basename path
    d = ::File.extname( path ).length
    d.zero? ? bn : bn[ 0 ... - d ]
  end

  Expression_agent_from_legacy_ = Lazy_.call do
    _Zerk = Zerk_lib_[]
    _Zerk::API::InterfaceExpressionAgent::THE_LEGACY_CLASS.
      via_expression_agent_injection :_no_injection_from_BS_
  end

  Expression_agent_preferred_ = -> do
    ::NoDependenciesZerk::API_InterfaceExpressionAgent.instance
  end

  Ruby_current_version_fixture_file_ = -> tail do
    ::File.join Ruby_current_version_dir_[], tail
  end

  Ruby_current_version_dir_ = Lazy_.call do
    Fixture_file_[ 'ruby-current-version' ]
  end

  Fixture_function_path__ = -> tail do
    ::File.join Fixture_function_dir_[], tail
  end

  Fixture_function_dir_ = Lazy_.call do
    ::File.join TS_.dir_path, 'fixture-functions'
  end

  Fixture_tree_for_case_one_ = Lazy_.call do
    Fixture_file_[ 'tree-010-yadda' ]
  end

  Fixture_file_ = -> tail do
    ::File.join TS_.dir_path, 'fixture-files', tail
  end

  Zerk_test_support_ = -> do
    Zerk_lib_[].test_support
  end

  Zerk_lib_ = -> do
    Home_.lib_.zerk
  end

  # --

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  DASH_ = Home_::DASH_
  EMPTY_A_ = [].freeze  # (very important that you freeze)
  EMPTY_S_ = Home_::EMPTY_S_
  NEWLINE_ = Home_::NEWLINE_
    DELIMITER_ = NEWLINE_
  Autoloader_[ Models = ::Module.new ]  # some tests drill into this directly
  NIL_ = nil
    NIL = nil  # #open [#sli-116.C]
    FALSE = false  # #open [#sli-116.C]
  NOTHING_ = nil
  TS_ = self
  UNDERSCORE_ = Home_::UNDERSCORE_
end
