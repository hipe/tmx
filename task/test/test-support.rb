require 'skylab/task'
require 'skylab/test_support'

module Skylab::Task::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include Instance_Methods___
    end

    def lib sym
      _lib.public_library sym
    end

    def lib_ sym
      _lib.protected_library sym
    end

    def _lib
      @___lib ||= TestSupport_::Library.new TS_
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

    Use_method___ = -> sym do
      TS_.lib_( sym )[ self ]
    end

  module Instance_Methods___

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  Home_ = ::Skylab::Task
  Autoloader__ = Home_::Autoloader_

  module TestLib_

    sidesys = Autoloader__.build_require_sidesystem_proc

    system_lib = nil

    Tee = -> do
      system_lib[]::IO::Mappers::Tee
    end

    system_lib = sidesys[ :System ]
  end

  Autoloader__[ self, ::File.dirname( __FILE__ ) ]

  TS_ = self
end
