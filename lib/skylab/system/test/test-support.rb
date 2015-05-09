require_relative '../core'
require 'skylab/test-support/core'

module Skylab::System::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  module ModuleMethods

    define_method :use, -> do

      cache_h = {}

      -> sym do

        ( cache_h.fetch sym do

          const = Callback_::Name.via_variegated_symbol( sym ).as_const

          x = if Test_Support_Bundles___.const_defined? const, false
            Test_Support_Bundles___.const_get const, false
          else
            System_.lib_.brazen::Bundle::Fancy_lookup[ sym, TS_ ]
          end
          cache_h[ sym ] = x
          x
        end )[ self ]
      end

    end.call
  end

  module InstanceMethods

    def services_
      System_.services
    end

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  module Test_Support_Bundles___

    Expect_Event = -> test_context_class do
      Callback_.test_support::Expect_Event[ test_context_class ]
    end
  end

  System_ = ::Skylab::System

  Callback_ = System_::Callback_

  class << self

    define_method :tmpdir_path_, ( Callback_.memoize do

      ::File.join( System_.services.filesystem.tmpdir_path, '[sy]' )  # :+#FS-eek
    end )
  end  # >>

  EMPTY_S_ = System_::EMPTY_S_

  NIL_ = System_::NIL_

end

# (point of history - what used to be this node became [#br-xxx])
