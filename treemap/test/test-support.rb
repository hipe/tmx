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

  extend TestSupport_::Quickie

  # -

    Use_method___ = -> sym do
      :expect_event == sym or fail
      Home_::Common_.test_support::Expect_Emission[ self ]
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
