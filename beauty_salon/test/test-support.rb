# frozen_string_literal: true

require 'skylab/beauty_salon'
require 'skylab/test_support'

module Skylab::BeautySalon::TestSupport

  class << self
    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include InstanceMethods___
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  # -
    Use_method___ = -> do
      h = {}
      -> sym do
        ( h.fetch sym do
          x = TestSupport_.fancy_lookup sym, TS_
          h[ sym ] = x
          x
        end )[ self ]
      end
    end.call
  # -

  module InstanceMethods___

    def expect_these_lines_in_array_with_trailing_newlines_ a, & p
      TestSupport_::Expect_Line::
          Expect_these_lines_in_array_with_trailing_newlines[ a, p, self ]
    end

    def expect_these_lines_in_array_ a, & p
      TestSupport_::Expect_these_lines_in_array[ a, p, self ]
    end

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end

    def subject_CLI
      Home_::CLI
    end

    define_method :get_invocation_strings_for_expect_stdout_stderr, -> do

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

    # -- retrofit

    def expect_failed_by_ sym

      em = expect_not_OK_event
      em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
      expect_no_more_events
      @result.should eql false
      em
    end

    def expect_not_OK_event_ sym
      em = expect_not_OK_event
      em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
      em
    end

    def expect_OK_event_ sym=nil, msg=nil

      em = expect_OK_event nil, msg
      if sym
        em.cached_event_value.to_event.terminal_channel_symbol.should eql sym
      end
      em
    end
  end

  Home_ = ::Skylab::BeautySalon
  Lazy_ = Home_::Lazy_

  # -- bundles

  module My_CLI

    def self.[] tcc
      tcc.include self
    end

    def parse_help_screen_fail_early_

      string_st = to_errput_line_stream_strictly

      o = Zerk_test_support_[]::CLI::Expect_Section_Fail_Early.define
      yield o
      spy = o.finish.to_spy_under self
      io = spy.spying_IO

      begin
        line = string_st.gets
        line || break
        io.puts line
        redo
      end while above

      spy.finish
      NIL
    end

    define_method :invocation_strings_for_expect_stdout_stderr, ( Lazy_.call do
      [ 'chimmy' ].freeze
    end )

    def subject_CLI
      Home_::CLI2
    end
  end

  module My_API

    def self.[] tcc
      Memoizer_Methods[ tcc ]
      Expect_Emission_Fail_Early[ tcc ]
      tcc.include self
    end

    def expect_API_result_for_failure_
      expect_result nil
    end

    def expect_API_result_for_success_  # track this idea
      expect_result nil
    end

    def expression_agent
      ::NoDependenciesZerk::API_InterfaceExpressionAgent.instance
    end

    def ignore_emissions_whose_terminal_channel_is_in_this_hash
      NOTHING_
    end

    def subject_API
      Home_::API::API2  # #open [#023]
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
        :deliterate,
      ].freeze
    end )
  end

  Expect_Event = -> tcc do
    Common_.test_support::Expect_Emission[ tcc ]
  end

  Expect_Emission_Fail_Early = -> tcc do
    Common_.test_support::Expect_Emission_Fail_Early[ tcc ]
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  CLI = -> tcc do
    Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
  end

  Non_Interactive_CLI = -> tcc do
    Home_.lib_.zerk.test_support::Non_Interactive_CLI[ tcc ]
  end

  # --

  def self._MY_BIN_PATH
    @___mbp ||= ::File.expand_path( '../../bin', __FILE__ )
  end

  # --

  Fixture_file_ = -> tail do  # 1x
    ::File.join TS_.dir_path, 'fixture-files', tail
  end

  Zerk_test_support_ = -> do
    Home_.lib_.zerk.test_support
  end

  # --

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]


    NEWLINE_ = Home_::NEWLINE_
  DELIMITER_ = NEWLINE_
  EMPTY_S_ = Home_::EMPTY_S_
  Autoloader_[ Models = ::Module.new ]  # some tests drill into this directly
  NIL_ = nil
    NIL = nil  # #open [#sli-116.C]
    FALSE = false  # #open [#sli-116.C]
  NOTHING_ = nil
  TS_ = self
end
