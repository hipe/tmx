require_relative '..'
require 'skylab/callback/core'

module Skylab::Permute

  class << self

    def application_kernel_

      @___kr ||= Pe_.lib_.brazen::Kernel.new Pe_
    end

    def lib_

      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  KEEP_PARSING_ = true
  NIL_ = nil
  Pe_ = self
  UNABLE_ = false
  UNDERSCORE_ = '_'
end
