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

    def existent_tmpdir_path
      memoized_tmpdir_.to_path
    end

    define_method :memoized_tmpdir_, -> do

      o = nil
      -> do
        if o
          o.for self
        else
          o = TestSupport_.tmpdir.memoizer_for self, 'bertie-serern'
          o.instance
        end
      end
    end.call

    def tmpdir_path_for_memoized_tmpdir
      Home_.lib_.system.filesystem.tmpdir_path
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

    def black_and_white_expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
    end
  end

  # ~ bundles

  Expect_Event = -> tcc do
    Callback_.test_support::Expect_Event[ tcc ]
  end

  Expect_Interactive = -> tcc do
    Home_.lib_.brazen.test_support.lib( :Zerk_expect_interactive )[ tcc ]
  end

  Modality_Integrations_CLI_Support = -> tcc do
    Home_.lib_.brazen.test_support.lib( :CLI_expectations )[ tcc ]
  end

  # ~

  def self._COMMON_DIR
    @___common_dir ||= TestSupport_::Fixtures.files_path
  end

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
