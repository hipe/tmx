require_relative '..'
require 'skylab/callback/core'

module Skylab::GitViz

  class << self

    def describe_into_under y, _
      y << "awesome, simple tabular visualiztion of a repository over time"
    end

    def mock_FS
      Home_.lib_.mock_system_lib::Mock_FS
    end

    def repository
      Home_::VCS_Adapters_::Git.repository
    end
  end  # >>

  module CLI  # :+#stowaway

    class << self

      def new * a

        client = Home_.lib_.brazen::CLI.new_top_invocation(
          a, Home_.application_kernel_ )

        client.receive_environment MONADIC_EMPTINESS_

        client
      end
    end  # >>
  end

  module API

    class << self

      def call * x_a, & oes_p
        bc = Home_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end
    end  # >>
  end

  Callback_ = ::Skylab::Callback

  class << self

    define_method :application_kernel_, ( Callback_.memoize do
      Home_.lib_.brazen::Kernel.new Home_
    end )

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  Actors_ = ::Module.new
  Actors_::Relpath = -> long, short do

    d = short.length
    short == long[ 0, d ] or raise ::ArgumentError
    FILE_SEPARATOR_BYTE_ == long.getbyte( d ) or raise ::ArgumentError

    if short.length + 1 == d
      NIL_  # long path was just short path with trailing slash
    else
      long[ d + 1 .. -1 ]
    end
  end

  Autoloader_ = ::Skylab::Callback::Autoloader
  ACHIEVED_ = true
  Callback_Tree_ = Callback_::Tree
  CONTINUE_ = nil
  DASH_ = '-'.freeze
  DOT_ = '.'.freeze
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  FILE_SEPARATOR_BYTE_ = ::File::SEPARATOR.getbyte 0
  Home_ = self
  Name_ = Callback_::Name
  NEWLINE_ = "\n"
  NIL_ = nil
  MONADIC_EMPTINESS_ = -> _ {}
  Scn_ = Callback_::Scn
  SPACE_ = ' '.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

end

# :#tombstone: [#005]:#this-node-looks-funny-because-it-is-multi-domain
