module Skylab::Zerk

  class InteractiveCLI  # intro to local name convention in [#004]

    class << self
      def begin
        Require_fields_lib_[]  # or wherever
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

    def filesystem_conduit= x
      @filesystem_conduit_known_known = Common_::KnownKnown[ x ] ; nil
    end

    def root_ACS_by & p
      @root_ACS_proc = p
    end

    def system_conduit= x
      @system_conduit_known_known = Common_::KnownKnown[ x ] ; nil
    end

    attr_writer(
      :argv,
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
      :filesystem_conduit_known_known,
      :program_name_string_array,
      :serr,
      :sin,
      :sout,
      :system_conduit_known_known,
    )

    def execute

      argv = remove_instance_variable :@argv

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

      @boundarizer = Home_::CLI::Section::Boundarizer.new line_yielder

      vmm = Here_::View_Maker_Maker___.instance

      if @design
        vmm = vmm.dup  # (hi.)
        vmm = @design[ vmm ]
      end

      _el = Here_::Event_Loop___.new vmm, self, & @root_ACS_proc

      Common_::BoundCall.via_receiver_and_method_name _el, :run
    end

    def ___init_expression_agent

      @_expression_agent = Home_::CLI::InterfaceExpressionAgent::
          THE_LEGACY_CLASS.proc_based_by do |o|

        o.expression_strategy_for_property = -> _prp do
          :render_property_in_black_and_white_customly
        end

        o.render_property_in_black_and_white_customly = -> prp, _expag do
          prp.name.as_human
        end
      end
      NIL
    end

    def receive_uncategorized_emission i_a, & ev_p

      bc = Common_::Emission::Interpreter.common[ i_a, & ev_p ]
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

    attr_reader :root_ACS_proc

    # ==

    Build_frame_stack_as_array_ = -> top_frame do

      link = Basic_[]::List::Linked
      current_link = link[ NOTHING_, top_frame ]
      begin
        fr = current_link.element_x.below_frame
        fr or break
        current_link = link[ current_link, fr ]
        redo
      end while nil
      a = []
      begin
        a.push current_link.element_x
        current_link = current_link.next
      end while current_link
      a
    end

    # ==

    Remote_CLI_lib_ = Home_::CLI_::Remote_lib

    Here_ = self
    NUMBER_OF_LINES_PER_ITEM_ = 2
  end
end
