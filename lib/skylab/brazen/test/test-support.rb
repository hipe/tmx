require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Brazen::TestSupport

  class << self

    def expect_event x
      Brazen_::TestSupport::Expect_Event[ x ]
    end
  end

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  Brazen_ = ::Skylab::Brazen

  Callback_ = Brazen_::Callback_

  TestLib_ = ::Module.new

  module Constants
    Brazen_ = Brazen_
    EMPTY_S_ = ''.freeze
    Entity_ = Brazen_::Entity_
    SPACE_ = ' '.freeze
    TestLib_ = TestLib_
    TestSupport_ = TestSupport_
  end

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def prepared_tmpdir
      td = TS_::TestLib_::Tmpdir[]
      if do_debug
        if ! td.be_verbose
          td = td.with :be_verbose, true, :debug_IO, debug_IO
        end
      elsif td.be_verbose
        self._IT_WILL_BE_EASY
      end
      td.prepare
      td
    end

    def event_expression_agent
      @eea ||= begin
        Brazen_::API.expression_agent_class.new Brazen_::API.application_kernel
      end
    end

    def cfn
      Brazen_::Models_::Workspace.config_filename
    end
  end

  module TestLib_

    memoize = Brazen_::Callback_.memoize

    Expect_Event = -> test_context_cls do
      TS_::Expect_Event[ test_context_cls ]
    end

    Fileutils = Callback_.memoize do
      require 'fileutils'
      ::FileUtils
    end

    Tmpdir = memoize[ -> do
      sys = Brazen_::Lib_::System[]
      _path = sys.defaults.dev_tmpdir_pathname.join( 'brzn' ).to_path
      sys.filesystem.tmpdir :path, _path
    end ]

    System = Brazen_::Lib_::System

  end

  module Fixtures
    Callback_::Autoloader[ self ]  # don't load fixture file when autoloading lib
  end

  module Zerk
    Callback_::Autoloader[ self ]  # don't load spec file when autoloading lib
  end
end
