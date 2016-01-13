module Skylab::Zerk

  class InteractiveCLI

    # [#001] "interactive CLI" is zerk's main modality. as such most of
    # the sidesystem is in service of this node. the tree doesn't reflect
    # this fully because:
    #
    #   • aesthetics: it's a bit of a "bump" cramming this all into
    #     the toplevel.
    #
    #   • putting all the tributary nodes "under" this one, then, makes the
    #     tree "feel" too deep. if we want to "grow out" the other
    #     modalities, it is *they* that should either grow downward
    #     or be in a different library.

    class << self
      def begin
        new.__init_as_beginning
      end
      private :new
    end  # >>

    def initialize_copy _
      # (hi.) (`dup` called below)
      NIL_
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
      Home_::CLI_Support_::Prototype_as_Classesque.new self
    end

    def universal_CLI_resources sin, sout, serr, pn_s_a
      @sin = sin
      @sout = sout
      @serr = serr
      @program_name_string_array = pn_s_a
      NIL_
    end

    def __accept_resources sin, sout, serr, pn_s_a
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

      @boundarizer =
        Home_.lib_.brazen::CLI_Support::Section::Boundarizer.new(
          line_yielder )

      vmm = Here_::View_Maker_Maker___.instance

      if @design
        vmm = vmm.dup  # (hi.)
        vmm = @design[ vmm ]
      end

      _el = Here_::Event_Loop___.new vmm, self, & @_root_ACS_proc

      Callback_::Bound_Call.via_receiver_and_method_name _el, :run
    end

    def receive_uncategorized_emission i_a, & ev_p

      bc = Callback_::Emission::Interpreter.common[ i_a, & ev_p ]
      _ = send bc.method_name, * bc.args, & bc.block
      UNRELIABLE_
    end

    def receive_conventional_emission i_a, & ev_p

      _ev = ev_p[]
      _y = line_yielder
      _expag = _expression_agent

      _ev.express_into_under _y, _expag

      @boundarizer.touch_boundary

      UNRELIABLE_
    end

    def receive_expression_emission i_a, & y_p

      # (came from #thread-one)

      _y = line_yielder
      _expag = _expression_agent

      _expag.calculate _y, & y_p

      UNRELIABLE_
    end

    def _expression_agent
      Home_.lib_.brazen::CLI.expression_agent_instance
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

    Here_ = self
  end
end
