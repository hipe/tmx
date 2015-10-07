require 'skylab/brazen'

module Skylab::Slicer

  module API

    class << self

      def call * x_a, & oes_p
        bc = Home_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args, & bc.block
      end

      def expression_agent_class
        Brazen_::API.expression_agent_class
      end

      def expression_agent_instance
        Brazen_::API.expression_agent_instance
      end
    end  # >>
  end

  class << self

    def data_documents_path
      ::File.expand_path '../../../data-documents', dir_pathname.to_path
    end

    def describe_into_under y, _
      y << "(secret)"
    end

    def distribute_sigils ss_a

      ea = Home_::Actors_::Determine_and_distribute_medallions[ ss_a ]
      begin
        begin
          ea.next
          redo
        rescue ::StopIteration
          break
        end
      end while nil
      NIL_
    end

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

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    Task = sidesys[ :Task ]

  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]

  stowaway :CLI do

    CLI = ::Class.new Brazen_::CLI
  end

  ACHIEVED_ = true
  Brazen_ = Autoloader_.require_sidesystem :Brazen
  EMPTY_S_ = ''.freeze
  NIL_ = nil
  Home_ = self
  UNABLE_ = false

end
