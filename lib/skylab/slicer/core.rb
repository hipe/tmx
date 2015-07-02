require_relative '..'
require 'skylab/callback/core'

module Skylab::Slicer

  class << self

    def application_kernel_

      @___ak ||= Brazen_::Kernel.new Home_
    end

    def lib_
      @___lb ||= Callback_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module Lib_

    # sidesys, = Autoloader_.at :build_require_sidesystem_proc

  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  Brazen_ = Autoloader_.require_sidesystem :Brazen
  Autoloader_[ ( Models_ = ::Module.new ), :boxxy ]
  NIL_ = nil
  Home_ = self
  THE_EMPTY_MODULE_ = ::Module.new

end
