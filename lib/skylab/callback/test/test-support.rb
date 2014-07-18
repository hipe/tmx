require_relative '../core'

module Skylab::Callback::TestSupport

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  module CONSTANTS
    Callback_ = Callback_
    Callback = Callback_
    TestSupport = Callback_::Autoloader.require_sidesystem :TestSupport
  end

  Autoloader_[ self, Callback_.dir_pathname.join( 'test' ) ]

  CONSTANTS::TestSupport::Regret[ self ]

  module InstanceMethods

    -> do
      p = -> do
        pn = Callback_::TestSupport.dir_pathname.join 'fixtures'
        p = -> { pn } ; pn
      end
      define_method :fixtures_dir_pn do
        p[]
      end
    end.call
  end
end
