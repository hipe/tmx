require 'skylab/brazen'

module Skylab::Slicer

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  lazily :CLI do
    class CLI < Brazen_::CLI

      expose_executables_with_prefix 'tmx-slicer-'

      self
    end
  end

  module API

    class << self

      def call * x_a, & oes_p
        bc = Home_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end

      def expression_agent_instance
        Brazen_::API.expression_agent_instance
      end
    end  # >>
  end

  class << self

    def describe_into_under y, _
      y << "(secret)"
    end

    def application_kernel_
      @___ak ||= Brazen_::Kernel.new Home_
    end

    def lib_
      @___lb ||= Common_.produce_library_shell_via_library_and_app_modules(
       Lib_, self )
    end
  end  # >>

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]
    Task = sidesys[ :Task ]
    TMX = sidesys[ :TMX ]
  end

  ACHIEVED_ = true
  Brazen_ = Autoloader_.require_sidesystem :Brazen
  NIL_ = nil
  Home_ = self
  UNABLE_ = false
end
