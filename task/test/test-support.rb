require 'skylab/task'
require 'skylab/test_support'

module Skylab::Task::TestSupport

  class << self

    h = {}
    define_method :lib do | sym |

      h.fetch sym do
        x = TestSupport_.fancy_lookup sym, TS_
        h[ sym ] = x
        x
      end
    end
  end  # >>

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

  TestSupport_ = ::Skylab::TestSupport
  TS_ = self

end
