# encoding: UTF-8

module Skylab::TreetopTools

  DSL = ::Module.new

  class DSL::Shell  # #the-shell-narrative

    extend LIB_.parameter::Definer::ModuleMethods

    include LIB_.parameter::Definer::InstanceMethods::ActualParametersIvar

    class << self  # #note-15

      def actual_parameters_class
        const_defined? AP__, false or init_actual_parameters_class
        const_get AP__, false
      end

    private

      def init_actual_parameters_class
        _i_a = parameters.each.map( & :normalized_parameter_name )
        cls = ::Struct.new( * _i_a )
        cls.class_exec do
          include LIB_.parameter::Definer::InstanceMethods::StructAdapter
          public :known?
        end
        const_set AP__, cls ; nil
      end

      AP__ = :ActualParameters
    end

    def initialize
      @actual_parameters = self.class.actual_parameters_class.new
    end

    def __actual_parameters
      @actual_parameters
    end
  end

  DSL::Client = ::Module.new

  class DSL::Client::Minimal  # #the-minimal-DSL-client-narrative

    LIB_.parameter[ self, :parameter_controller,
      :oldschool_parameter_error_structure_handler ]

    include LIB_.parameter::Definer::InstanceMethods::IvarsAdapter

    def initialize client_x, dsl_body_p, event_p
      @dsl_body_p, @event_p = dsl_body_p, event_p
      super client_x
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
      end.new( & @event_p )
      # o.on_info = p  # #open [#004]
      @event_p = nil
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
      LIB_.CLI::IO.some_errstream_IO
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
  end
end
