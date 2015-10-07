require 'skylab/callback'

module Skylab::Git

  def self.describe_into_under y, _
    y << "assorted novelties for manipulating reository content (versioned or not)"
  end

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ]]

  stowaway :CLI do

    class CLI < Home_.lib_.brazen::CLI

      expose_executables_with_prefix 'tmx-git-'

      def back_kernel
        Home_::API.application_kernel_
      end

      self
    end
  end

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
