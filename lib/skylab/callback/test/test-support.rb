require_relative '../core'

module Skylab::Callback::TestSupport

  Callback = ::Skylab::Callback

  module CONSTANTS
    Callback = Callback
  end

  Callback::Autoloader.require_sidesystem( :TestSupport )::Regret[ self ]

  module InstanceMethods

    -> do
      p = -> do
        pn = Callback::TestSupport.dir_pathname.join 'fixtures'
        p = -> { pn } ; pn
      end
      define_method :fixtures_dir_pn do
        p[]
      end
    end.call
  end

  IDENTITY_ = -> x { x }
end
