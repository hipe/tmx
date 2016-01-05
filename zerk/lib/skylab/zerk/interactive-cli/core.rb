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

      alias_method :_orig_new, :new

      def new * args, & mixed_p

        if args.length.zero?
          ___make_class( & mixed_p )
        else
          cli = _orig_new( * args )
          cli._top_builder_proc = mixed_p
          cli
        end
      end

      def ___make_class( & p )
        cls = ::Class.new self
        class << cls
          alias_method :new, :_orig_new
        end
        cls.send :define_method, :_top_builder_proc do
          p
        end
        cls
      end
    end  # >>

    def initialize sin, sout, serr, pn_s_a

      @program_name_string_array = pn_s_a
      @serr = serr
      @sin = sin
      @sout = sout

      @design = nil
    end

    attr_writer(
      :design,
    )

    attr_reader(
      :argv,
      :boundarizer,
      :program_name_string_array,
      :serr,
      :sin,
      :sout,
    )

    attr_accessor :_top_builder_proc

    def invoke argv

      if argv.length.zero?

        bc = ___bound_call_for_event_loop
        x = bc.receiver
        yield x if block_given?  # :/
        x.send bc.method_name, * bc.args, & bc.block

      elsif %r(\A-(?:h|-h(?:e(?:l(?:p)?)?)?)\z)i =~ argv.first

        @serr.puts "usage: '#{ @program_name_string_array * SPACE_ }'"
        SUCCESS_EXITSTATUS
      else
        self._DESIGN_ME
      end
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

      _el = Here_::Event_Loop___.new vmm, self, & _top_builder_proc

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
