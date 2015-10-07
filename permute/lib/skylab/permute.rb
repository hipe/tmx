require 'skylab/callback'

module Skylab::Permute

  class << self

    def describe_into_under y, _
      y << "display permutations. sort of a stalking horse frontier prorotype"
    end

    def application_kernel_

      @___kr ||= Home_.lib_.brazen::Kernel.new Home_
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

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  KEEP_PARSING_ = true
  NIL_ = nil
  Home_ = self
  UNABLE_ = false
  UNDERSCORE_ = '_'
end
