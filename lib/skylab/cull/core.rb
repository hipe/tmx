require_relative '../callback/core'

module Skylab::Cull

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  class << self

    def _lib
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  module Lib_  # :+[#su-001]

    sidesys = Autoloader_.build_require_sidesystem_proc

    HL__ = sidesys[ :Headless ]

    Filesystem = -> do
      HL__[].system.filesystem
    end
  end

  Brazen_ = Autoloader_.require_sidesystem :Brazen

  module API

    class << self

      include Brazen_::API.module_methods

      def expression_agent_class
        Brazen_::API.expression_agent_class
      end
    end
  end

  Kernel_ = Brazen_.kernel_class

  Action_ = Brazen_.model.action_class  # for name stop index we need this const

  Cull_ = self

  Model_ = Brazen_.model.model_class

  Autoloader_[ self, ::Pathname.new( ::File.dirname( __FILE__ ) ) ]

end
