# encoding: UTF-8

module Skylab::TanMan

  # ~ begin stowaway

  module Input_Adapters_::Treetop

    class << self

      def new_parse
        Treetop_::Parser__.new
      end
    end  # >>

    LIB_ = Home_.lib_

    PROCEDE_ = true

    Treetop_ = self  # ~ stowaway

  # ~ end

    # <- (net: -1)

  module DSL_  # see [#008]

    # <- (net: -2)

  class Shell  # #the-shell-narrative

    extend LIB_.parameter::Definer_Module_Methods

    class << self  # #note-15

      def actual_parameters_class
        const_defined? AP__, false or init_actual_parameters_class
        const_get AP__, false
      end

    private

      def init_actual_parameters_class

        cls = ::Struct.new( * parameters.get_names )

        cls.class_exec do
          include LIB_.parameter::Struct_Adapter_Methods
          public :known?
        end

        const_set AP__, cls ; nil
      end
    end  # >>

    AP__ = :ActualParameters

    def initialize
      @actual_parameters = self.class.actual_parameters_class.new
    end

    def __actual_parameters
      @actual_parameters
    end

    # ~ begin this used to be [#fi-009.D] an i.m module. was de-abstracted

    private

    def known? k
      @actual_parameters.known? k
    end

    def [] k
      @actual_parameters[ k ]
    end

    def []= k, x
      @actual_parameters[ k ] = x
    end

    # ~ end
  end

  class Client  # #the-minimal-DSL-client-narrative

    LIB_.parameter[ self, :parameter_controller,
      :oldschool_parameter_error_structure_handler ]

    include LIB_.parameter::Ivars_Adapter_Methods

    def initialize dsl_body_p, * wiring_p_a, & p

      ::Proc == dsl_body_p.class or self._WHERE

      @dsl_body_p = dsl_body_p

      @_error_count = 0

      p and wiring_p_a.push p

      @__wiring_p = wiring_p_a.fetch( wiring_p_a.length - 1 << 1 )  # assert exactly 1
    end

  private

    def absrb_struct_into_ivars struct
      struct.members.each do |name|
        instance_variable_set "@#{ name }", struct[ name ]
      end
      PROCEDE_
    end

    def build_shell
      shell_class.new
    end

    def call_body_and_absorb!
      @shell ||= build_shell  # persist across bodies
      @dsl_body_p[ @shell ]
      actuals = @shell.__actual_parameters
      ok = set! nil, actuals
      if ok
        absrb_struct_into_ivars actuals
        PROCEDE_
      else
        UNABLE_
      end
    end

    def call_digraph_listeners type, payload
      callbacks[ type ][ payload ]
    end

    def callbacks
      @callbacks ||= bld_callbacks
    end

    def bld_callbacks
      o = LIB_.parameter::Definer.new do
        param :error, hook: true, writer: true
        param :info,  hook: true, writer: true
        alias_method :on_error, :error # hm ..
        alias_method :on_info, :info
      end.new( & remove_instance_variable( :@__wiring_p ) )
      # o.on_info = p  # #open [#004]
      o.on_error ||= default_handle_error_message
      o.on_info ||= default_handle_info_message
      o
    end

    def default_handle_error_message
      -> msg do
        fail "Couldn't #{ verb } #{ noun } -- #{ msg }"
      end
    end

    def default_handle_info_message
      -> msg do
        _msg_ = "(⌒▽⌒)☆  #{ msg }  ლ(́•◞౪◟•‵)ლ "
        some_infostream.puts _msg_ ; nil
      end
    end

    def some_infostream
      LIB_.system.IO.some_stderr_IO
    end

    def formal_parameters
      shell_class.parameters
    end

    def shell_class
      self.class.const_get :Shell__, false  # :+#hook-out
    end

    def noun
      NOUN__
    end
    NOUN__ = "grammar".freeze

    def verb
      VERB__
    end
    VERB__ = "load".freeze

    # ~ begin sub-client rehabilitation

    def error_count

      @_error_count
    end
    # ~ end
  end
  # -> (net: -1)
  end
  # -> (net: 0)
  end
end
