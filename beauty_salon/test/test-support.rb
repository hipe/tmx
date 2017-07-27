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

  # -- bundles

  Expect_Event = -> tcc do
    Common_.test_support::Expect_Emission[ tcc ]
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  CLI = -> tcc do
    Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
  end

  # --

  def self._MY_BIN_PATH
    @___mbp ||= ::File.expand_path( '../../bin', __FILE__ )
  end

  # --

  Fixture_file_ = -> tail do  # 1x
    ::File.join TS_.dir_path, 'fixture-files', tail
  end

  # --

  Home_ = ::Skylab::BeautySalon
  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  DELIMITER_ = Home_::NEWLINE_
  EMPTY_S_ = Home_::EMPTY_S_
  Autoloader_[ Models = ::Module.new ]  # some tests drill into this directly
  NIL_ = nil
    FALSE = false  # #open [#sli-116.C]
  NOTHING_ = nil
  TS_ = self
end
