require 'skylab/beauty_salon'
require 'skylab/test_support'

module Skylab::BeautySalon::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  extend TestSupport_::Quickie

  module ModuleMethods

    define_method :use, -> do
      h = {}
      -> sym do
        ( h.fetch sym do
          x = TestSupport_.fancy_lookup sym, TS_
          h[ sym ] = x
          x
        end )[ self ]
      end
    end.call
  end

  module InstanceMethods

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

  # ~ bundles

  Expect_Event = -> tcc do
    Callback_.test_support::Expect_Event[ tcc ]
  end

  Memoizer_Methods = -> tcc do
    TestSupport_::Memoization_and_subject_sharing[ tcc ]
  end

  Modality_Integrations_CLI_Support = -> tcc do
    Home_.lib_.brazen.test_support.lib( :CLI_support_expectations )[ tcc ]
  end

  # ~

  def self._MY_BIN_PATH
    @___mbp ||= ::File.expand_path( '../../bin', __FILE__ )
  end

  # ~
  Home_ = ::Skylab::BeautySalon
  Callback_ = ::Skylab::Callback
  Autoloader_ = Callback_::Autoloader

  DELIMITER_ = Home_::NEWLINE_
  EMPTY_S_ = Home_::EMPTY_S_
  Autoloader_[ Models = ::Module.new ]  # some tests drill into this directly
  NIL_ = nil

end
