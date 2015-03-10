require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Brazen::TestSupport

  class << self
    def expect_interactive x
      self::Zerk::Expect_Interactive[ x ]
    end
  end

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  TestSupport_::Regret[ TS_ = self ]

  Brazen_ = ::Skylab::Brazen

  Callback_ = Brazen_::Callback_

  TestLib_ = ::Module.new

  module Constants
    Brazen_ = Brazen_
    EMPTY_S_ = ''.freeze
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
          td = td.new_with :be_verbose, true, :debug_IO, debug_IO
        end
      elsif td.be_verbose
        self._IT_WILL_BE_EASY
      end
      td.prepare
      td
    end

    def black_and_white_expression_agent_for_expect_event
      @eea ||= begin
        Brazen_::API.expression_agent_class.new Brazen_.application_kernel_
      end
    end

    def cfg_filename
      Brazen_::Models_::Workspace.default_config_filename
    end

    def subject_API
      Brazen_::API
    end
  end

  module TestLib_

    memoize = Brazen_::Callback_.memoize

    Expect_event = -> test_context_cls do
      Callback_.test_support::Expect_Event[ test_context_cls ]
    end

    Fileutils = Callback_.memoize do
      require 'fileutils'
      ::FileUtils
    end

    Tmpdir = memoize.call do
      sys = Brazen_::LIB_.system
      _path = sys.defaults.dev_tmpdir_pathname.join( 'brzn' ).to_path
      sys.filesystem.tmpdir :path, _path
    end
  end

  Enhance_for_test_ = -> mod do
    mod.send :define_singleton_method, :with, WITH_MODULE_METHOD_
    mod.include Test_Instance_Methods_
    nil
  end

  WITH_MODULE_METHOD_ = -> * x_a do
    ok = nil
    x = new do
      ok = process_iambic_stream_fully iambic_stream_via_iambic_array x_a
    end
    ok && x
  end

  module Test_Instance_Methods_

    attr_reader :bx

    def process_fully * x_a
      process_iambic_stream_fully iambic_stream_via_iambic_array x_a
    end

  private

    def procez * x_a
      _st = iambic_stream_via_iambic_array x_a
      _ok = process_iambic_stream_fully _st
      _ok && normalize
    end

    def actual_property_box
      @bx ||= Brazen_::Box_.new
    end
  end

  module Fixtures
    Callback_::Autoloader[ self ]  # don't load fixture file when autoloading lib
  end

  module Zerk
    Callback_::Autoloader[ self ]  # don't load spec file when autoloading lib
  end
end
