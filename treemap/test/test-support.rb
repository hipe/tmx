require 'skylab/treemap'
require 'skylab/test_support'

module Skylab::Treemap::TestSupport

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

    eek = {
      common_magnets_and_models: -> tcc do
        TS_::Common_Magnets_And_Models[ tcc ]
      end,
      expect_event: -> tcc do
        Home_::Common_.test_support::Expect_Emission[ tcc ]
      end,
      memoizer_methods: -> tcc do
        TestSupport_::Memoization_and_subject_sharing[ tcc ]
      end,
    }

    Use_method___ = -> sym do
      eek.fetch( sym )[ self ]
    end
  # -

  module InstanceMethods___

    def debug!
      @do_debug = true
    end
    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def subject_API
      Home_.application_kernel_
    end
  end

  Fixture_file_ = -> do

    p = -> path do
      dirname = ::File.join TS_.dir_path, 'fixture-files'
      p = -> path_ do
        ::File.join dirname, path_
      end
      p[ path ]
    end

    -> path do
      p[ path ]
    end
  end.call

  class << self
    def string_IO
      require 'stringio'
      ::StringIO
    end
  end  # >>

  Home_ = ::Skylab::Treemap

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  TS_ = self
end
