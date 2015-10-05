require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Brazen::TestSupport

  class << self

    def CLI
      require_relative 'cli/test-support'
      CLI
    end

    def expect_interactive x
      self::Zerk::Expect_Interactive[ x ]
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  TestSupport_::Regret[ TS_ = self ]

  module ModuleMethods

    define_method :use, -> do

      cache_h = {}

      -> sym do
        ( cache_h.fetch sym do

          s = sym.id2name
          const = :"#{ s[ 0 ].upcase }#{ s[ 1 .. -1 ] }"
          x = if TestLib_.const_defined? const, false
            TestLib_.const_get const
          else
            TestSupport_.fancy_lookup sym, TS_
          end
          cache_h[ sym ] = x
          x
        end )[ self ]
      end
    end.call
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
        Home_::API.expression_agent_class.new Home_.application_kernel_
      end
    end

    def cfg_filename
      Home_::Models_::Workspace.default_config_filename
    end

    def subject_API
      Home_::API
    end
  end

  Callback_ = ::Skylab::Callback

  module TestLib_

    memoize = Callback_::Memoize

    Danger_memo = -> tcc do
      tcc.send :define_singleton_method,
        :dangerous_memoize_,
        TestSupport_::DANGEROUS_MEMOIZE
    end

    Expect_event = -> test_context_cls do
      Callback_.test_support::Expect_Event[ test_context_cls ]
    end

    Fileutils = Callback_.memoize do
      require 'fileutils'
      ::FileUtils
    end

    Tmpdir = memoize.call do
      sys = Home_::LIB_.system
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
      ok = process_polymorphic_stream_fully(
        Callback_::Polymorphic_Stream.via_array x_a )
    end
    ok && x
  end

  module Test_Instance_Methods_

    def initialize & edit_p
      instance_exec( & edit_p )
    end

  # ~ to be an entity (model or action) you have to:

    def knownness_via_property_ prp  # :+#cp

      if bx
        had = true
        x = bx.fetch prp.name_symbol do
          had = false
        end
      end

      if had
        Callback_::Known.new_known x
      else
        Callback_::Known::UNKNOWN
      end
    end

    def as_entity_actual_property_box_
      @bx ||= Home_::Box_.new
    end

    def handle_event_selectively
      NIL_
    end

  # ~ for these tests

    attr_reader :bx

    private def process_and_normalize_for_test_ * x_a

      _st = Callback_::Polymorphic_Stream.via_array x_a
      _ok = process_polymorphic_stream_fully _st
      _ok && normalize
    end

    def process_fully_for_test_ * x_a

      process_polymorphic_stream_fully(
        Callback_::Polymorphic_Stream.via_array x_a )
    end
  end

  module Fixtures
    Callback_::Autoloader[ self ]  # don't load fixture file when autoloading lib
  end

  module Zerk
    Callback_::Autoloader[ self ]  # don't load spec file when autoloading lib
  end

  EMPTY_S_ = ''.freeze
  Home_ = ::Skylab::Brazen
  NIL_ = nil
  SPACE_ = ' '.freeze

  module Constants
    Home_ = Home_
    Callback_ = Callback_
    EMPTY_S_ = EMPTY_S_
    SPACE_ = SPACE_
    TestLib_ = TestLib_
    TestSupport_ = TestSupport_
  end
end
