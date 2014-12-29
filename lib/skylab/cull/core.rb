require_relative '../callback/core'

module Skylab::Cull

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  class << self

    def _lib
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Brazen_ = Autoloader_.require_sidesystem :Brazen

  module API

    class << self

      include Brazen_::API.module_methods

      def expression_agent_class
        Brazen_::API.expression_agent_class
      end
    end
  end

  HARD_CALL_METHOD_ = -> arg_box, & oes_p do

    seen = false

    x = new do
      seen = true

      st = self.class.properties.to_stream

      prp = st.gets
      while prp
        instance_variable_set(
          :"@#{ prp.name_symbol }_arg",
          arg_box.fetch( prp.name_symbol ) )
        prp = st.gets
      end

      @on_event_selectively = oes_p
    end

    seen && x.execute
  end

  VALUE_BOX_CALL_METHOD_ = -> value_box, & oes_p do

    seen = false

    x = new do
      seen = true

      st = self.class.properties.to_stream

      prp = st.gets
      while prp
        instance_variable_set :"@#{ prp.name_symbol }", value_box[ prp.name_symbol ]
        prp = st.gets
      end

      @on_event_selectively = oes_p
    end

    seen && x.execute
  end

  module Simple_Selective_Sender_Methods_
  private
    def maybe_send_event * i_a, & ev_p
      @on_event_selectively.call( * i_a, & ev_p )
    end

    def build_event_with * i_a, & msg_p
      Brazen_.event.inline_via_iambic_and_any_message_proc_to_be_defaulted i_a, msg_p
    end

    def handle_event_selectively
      @on_event_selectively
    end
  end

  module Lib_  # :+[#su-001]

    sidesys = Autoloader_.build_require_sidesystem_proc

    HL__ = sidesys[ :Headless ]

    Filesystem = -> do
      HL__[].system.filesystem
    end

    System = -> do
      HL__[].system
    end
  end

  ACHIEVED_ = true
  Action_ = Brazen_.model.action_class  # for name stop index we need this const
  Cull_ = self
  Kernel_ = Brazen_.kernel_class
  Model_ = Brazen_.model.model_class
  UNABLE_ = false

  Autoloader_[ self, ::Pathname.new( ::File.dirname( __FILE__ ) ) ]

end
