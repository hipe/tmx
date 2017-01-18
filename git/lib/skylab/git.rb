require 'skylab/common'

module Skylab::Git

  def self.describe_into_under y, _
    y << "assorted novelties for manipulating reository content (versioned or not)"
  end

  Common_ = ::Skylab::Common

  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  lazily :CLI do

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

    define_method :application_kernel_, ( Common_.memoize do
      Home_.lib_.brazen::Kernel.new Home_
    end )
  end  # >>

  Home_ = self

  class << Home_

    def check_SCM * a
      if a.length.zero?
        Home_::Check
      else
        Home_::Check.line_oriented_via_arguments__ a
      end
    end

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  module Models_

    module Branches

      module Actions

        Autoloader_[ self, :boxxy ]
      end

      Autoloader_[ self ]
    end

    Autoloader_[ self, :boxxy ]
  end

  Lazy_ = Common_::Lazy

  Require_brazen_ = Lazy_.call do

    Brazen_ = ::Skylab::Brazen
  end

  Process_ = -> * five do
    Home_.lib_.basic::Process.via_five( * five )
  end

  ProcLike_ = Common_::ProcLike

  ACHIEVED_ = true
  DASH_ = '-'.freeze
  DOT_ = '.'
  EMPTY_A_ = []
  EMPTY_P_ = -> { NIL_ }
  GIT_EXE_ = 'git'
  KEEP_PARSING_ = true
  NIL_ = nil
  NOTHING_ = nil
  SPACE_ = ' '
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze
end
