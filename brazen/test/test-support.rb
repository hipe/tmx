require 'skylab/brazen'
require 'skylab/test_support'

module Skylab::Brazen::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  module ModuleMethods

    def use sym
      TS_.lib_( sym )[ self ]
    end
  end

  class << self

    def lib sym
      LIB__.public_library sym
    end

    def lib_ sym
      LIB__.protected_library sym
    end
  end  # >>

  module LIB__ ; class << self

    # (special treatment for our experiment with public/protected..)

    def public_library sym
      ( @___public_lib ||= __build_public_library )[ sym ]
    end

    def __build_public_library

      cache = {}
      -> sym do
        cache.fetch sym do
          x = protected_library sym
          if x.const_defined? :PUBLIC, false
            yes = x.const_get :PUBLIC, false
          end
          if yes
            cache[ sym ] = x
            x
          else
            raise ::NameError, __say_etc( sym )
          end
        end
      end
    end

    def protected_library sym
      ( @___protected_lib ||= __build_protected_library )[ sym ]
    end

    def __build_protected_library

      cache = {}
      -> sym do
        cache.fetch sym do
          x = _lookup sym
          cache[ sym ] = x
          x
        end
      end
    end

    def _lookup sym
      s = sym.id2name
      const = :"#{ s[ 0 ].upcase }#{ s[ 1 .. -1 ] }"
      if @_close_lib.const_defined? const, false
        @_close_lib.const_get const
      else
        TestSupport_.fancy_lookup sym, @_far_lib
      end
    end

    def __say_etc sym
      "#{ @_far_lib.name } `#{ sym }` is not public but can be made public #{
        }by setting in it a constant `PUBLIC` with a true-ish value."
    end
  end ; end

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

    Expect_event = -> test_context_cls do
      Callback_.test_support::Expect_Event[ test_context_cls ]
    end

    Fileutils = Callback_.memoize do
      require 'fileutils'
      ::FileUtils
    end

    Memoizer_methods = -> tcc do
      TestSupport_::Memoization_and_subject_sharing[ tcc ]
    end

    Tmpdir = memoize.call do

      sys = Home_::LIB_.system

      _path = ::File.join sys.defaults.dev_tmpdir_path, 'brzn'

      sys.filesystem.tmpdir :path, _path
    end
  end

  module LIB__
    @_close_lib = TestLib_
    @_far_lib = TS_
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

    def knowness_via_association_ prp  # :+#cp

      if bx
        had = true
        x = bx.fetch prp.name_symbol do
          had = false
        end
      end

      if had
        Callback_::Known_Known[ x ]
      else
        Callback_::KNOWN_UNKNOWN
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

  EMPTY_S_ = ''.freeze
  Home_ = ::Skylab::Brazen
  NIL_ = nil
  SPACE_ = ' '.freeze

  module Constants
    Home_ = Home_
    Callback_ = Callback_
    EMPTY_S_ = EMPTY_S_
    NIL_ = nil
    SPACE_ = SPACE_
    TestLib_ = TestLib_
    TestSupport_ = TestSupport_
  end
end
