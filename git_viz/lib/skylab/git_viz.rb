require 'skylab/common'

module Skylab::GitViz

  class << self

    def describe_into_under y, _
      y << "awesome, simple tabular visualiztion of a repository over time"
    end

    def repository
      Home_::VCS_Adapters_::Git.repository
    end
  end  # >>

  Common_ = ::Skylab::Common

  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  lazily :CLI do

    class CLI < Home_.lib_.brazen::CLI

      def initialize * a

        super
        receive_environment MONADIC_EMPTINESS_
          # (we don't remember why we wanted the above, but now it's exercize)
      end

      self
    end
  end

  module API

    class << self

      def call * x_a, & oes_p
        bc = Home_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end
    end  # >>
  end

  class << self

    define_method :application_kernel_, ( Common_.memoize do
      Home_.lib_.brazen::Kernel.new Home_
    end )

    def lib_
      @lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  Actors_ = ::Module.new
  Actors_::Relpath = -> long, short do

    d = short.length
    short == long[ 0, d ] or raise ::ArgumentError
    Path_looks_absolute_[ long ] or raise ::ArgumentError

    if short.length + 1 == d
      NIL_  # long path was just short path with trailing slash
    else
      long[ d + 1 .. -1 ]
    end
  end

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Path_looks_absolute_ = -> path do
    Home_.lib_.system.path_looks_absolute path
  end

  ACHIEVED_ = true
  CONTINUE_ = nil
  DASH_ = '-'.freeze
  DOT_ = '.'.freeze
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  Home_ = self
  Name_ = Common_::Name
  NEWLINE_ = "\n"
  NIL_ = nil
  MONADIC_EMPTINESS_ = -> _ {}
  Scn_ = Common_::Scn
  SPACE_ = ' '.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze
end

# :#tombstone: [#005]:#this-node-looks-funny-because-it-is-multi-domain
