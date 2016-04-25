module Skylab::Zerk

  class InteractiveCLI  # see [#001].

    class << self
      def begin
        new.__init_as_beginning
      end
      private :new
    end  # >>

    def initialize_copy _
      NIL_  # (hi.) (`dup` called below)
    end

    def __init_as_beginning
      @design = nil
      @on_event_loop = nil  # ..
      self
    end

    def root_ACS= p
      @_root_ACS_proc = p
    end

    attr_writer(
      :design,
      :on_event_loop,
    )

    def to_classesque  # tracking #[#011]
      CLI_::Prototype_as_Classesque.new self
    end

    def universal_CLI_resources sin, sout, serr, pn_s_a
      @sin = sin
      @sout = sout
      @serr = serr
      @program_name_string_array = pn_s_a
      NIL_
    end

    def __accept_resources sin, sout, serr, pn_s_a
      self._THIS_aint_finished
      @sin
    end

    def finish
      # (nothing to do.)
      self
    end

    attr_reader(
      :argv,
      :boundarizer,
      :program_name_string_array,
      :serr,
      :sin,
      :sout,
    )

    def invoke argv

      if argv.length.zero?
        invoke_when_zero_length_argv
      else
        ___invoke_when_nonzero_length_argv argv
      end
    end

    def ___invoke_when_nonzero_length_argv argv

      _help_was_invoked = %r(\A-(?:h|-h(?:e(?:l(?:p)?)?)?)\z)i =~ argv.first

      if _help_was_invoked
        es = SUCCESS_EXITSTATUS
      else
        @serr.puts "unexpected argument: #{ argv.first.inspect }"
        es = GENERIC_ERROR_EXITSTATUS
      end
      @serr.puts "usage: '#{ @program_name_string_array * SPACE_ }'"
      es
    end

    def invoke_when_zero_length_argv

      bc = ___bound_call_for_event_loop
      evlo = bc.receiver

      if @on_event_loop
        @on_event_loop[ evlo ]  # testing only :/
      end

      evlo.send bc.method_name, * bc.args, & bc.block
    end

    def ___bound_call_for_event_loop

      ___init_expression_agent

      @boundarizer = Remote_CLI_lib_[]::Section::Boundarizer.new line_yielder

      vmm = Here_::View_Maker_Maker___.instance

      if @design
        vmm = vmm.dup  # (hi.)
        vmm = @design[ vmm ]
      end

      _el = Here_::Event_Loop___.new vmm, self, & @_root_ACS_proc

      Callback_::Bound_Call.via_receiver_and_method_name _el, :run
    end

    def ___init_expression_agent

      expag = Remote_CLI_lib_[]::Expression_Agent.new_proc_based

      expag.expression_strategy_for_property = -> _prp do
        :render_property_in_black_and_white_customly
      end

      expag.render_property_in_black_and_white_customly = -> prp, _expag do
        prp.name.as_human
      end

      @_expression_agent = expag ; nil
    end

    def receive_uncategorized_emission i_a, & ev_p

      bc = Callback_::Emission::Interpreter.common[ i_a, & ev_p ]
      _ = send bc.method_name, * bc.args, & bc.block
      UNRELIABLE_
    end

    def receive_conventional_emission i_a, & ev_p

      _ev = ev_p[]
      _y = line_yielder

      _ev.express_into_under _y, @_expression_agent

      @boundarizer.touch_boundary

      UNRELIABLE_
    end

    def receive_expression_emission _i_a, & y_p

      @_expression_agent.calculate line_yielder, & y_p

      UNRELIABLE_
    end

    def line_yielder
      @___line_yielder ||= ___build_line_yielder
    end

    def ___build_line_yielder
      io = @serr
      ::Enumerator::Yielder.new do | string |
        io.puts string
      end
    end

    Remote_CLI_lib_ = Lazy_.call do  # 2nd
      Home_.lib_.brazen::CLI_Support
    end

    Here_ = self
  end
end
