require 'skylab/callback'

module Skylab::Task

  class << self

    def test_support
      @___test_support ||= begin
        require_relative '../../test/test-support'
        Home_::TestSupport
      end
    end

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    Fields = sidesys[ :Fields ]

    String_IO = -> do
      require 'stringio' ; ::StringIO
    end
  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  CLI = nil  # for host
  Home_ = self
  NIL_ = nil
  UNABLE_ = false

end
