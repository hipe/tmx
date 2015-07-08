require_relative '..'
require 'skylab/callback/core'

module Skylab::Git

  Callback_ = ::Skylab::Callback

  API = ::Module.new

  class << API

    def call * x_a, & oes_p

      bc = application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
      if bc
        bc.receiver.send bc.method_name, * bc.args
      else
        bc
      end
    end

    define_method :application_kernel_, ( Callback_.memoize do
      Home_.lib_.brazen::Kernel.new Home_
    end )
  end  # >>

  Home_ = self

  class << Home_

    def check_SCM * a
      if a.length.zero?
        Home_::Actors__::Check_SCM
      else
        Home_::Actors__::Check_SCM[ * a ]
      end
    end

    def lib_
      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  DASH_ = '-'.freeze
  DOT_ = '.'
  EMPTY_A_ = []
  EMPTY_P_ = -> { NIL_ }
  GIT_EXE_ = 'git'
  KEEP_PARSING_ = true
  Autoloader_[ ( Models_ = ::Module.new ), :boxxy ]
  Autoloader_[ Models = ::Module.new ]
  NIL_ = nil
  SPACE_ = ' '
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

end
