require_relative '../core'
require 'skylab/test-support/core'

module Skylab::System::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  class << self

    def mocks
      TS_::MOCKS
    end
  end

  module ModuleMethods

    define_method :use, -> do

      cache_h = {}

      -> sym do

        ( cache_h.fetch sym do

          const = Callback_::Name.via_variegated_symbol( sym ).as_const

          x = if Test_Support_Bundles_.const_defined? const, false
            Test_Support_Bundles_.const_get const, false
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

    define_method :memoized_tmpdir_, ( -> do
      o = nil
      -> do
        if o
          o.for self
        else
          o = TestSupport_.tmpdir.memoizer_for self, 'sy-xyzzy'
          o.instance
        end
      end
    end ).call

    def fu_
      Home_.lib_.file_utils
    end

    def tmpdir_path_for_memoized_tmpdir
      real_filesystem_.tmpdir_path
    end

    def real_filesystem_
      services_.filesystem
    end

    def services_
      Home_.services
    end
  end

  module Test_Support_Bundles_

    Expect_Event = -> tcc do

      Callback_.test_support::Expect_Event[ tcc ]

      tcc.send :define_method,
          :black_and_white_expression_agent_for_expect_event do

        Home_.lib_.brazen::API.expression_agent_instance
      end
    end
  end

  Home_ = ::Skylab::System

  Callback_ = Home_::Callback_

  class << self

    define_method :tmpdir_path_, ( Callback_.memoize do

      ::File.join( Home_.services.filesystem.tmpdir_path, '[sy]' )  # :+#FS-eek
    end )
  end  # >>

  EMPTY_A_ = [].freeze
  EMPTY_S_ = Home_::EMPTY_S_

  NIL_ = Home_::NIL_

end

# (point of history - what used to be this node became [#br-xxx])
