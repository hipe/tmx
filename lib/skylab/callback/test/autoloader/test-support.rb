require_relative '../test-support'

module Skylab::Callback::TestSupport::Autoloader

  Callback_ = ::Skylab::Callback
  Callback_::TestSupport[ TS_ = self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Autoloader_ = Callback::Autoloader
  Callback = Callback

  module TestLib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Cull__ = sidesys[ :Cull ]

    Face__ = sidesys[ :Face ]

    Headless__ = sidesys[ :Headless ]

    MetaHell__ = Callback::Lib_::MetaHell__
  end
end
