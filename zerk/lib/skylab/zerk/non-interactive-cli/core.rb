module Skylab::Zerk

  class NonInteractiveCLI

    # for this class we follow the "prototype" pattern:
    #
    #   • this class is not meant to be subclassed.
    #
    #   • begin a prototype of this class by sending `begin` to the class.
    #
    #   • the prototype has "session performer" interface which is
    #     used to define the prototype.
    #
    #   • `dup` is then sent to the prototype to produce the client instance.
    #
    # the bulk of this is an implementation of the syntax conceived at [#014].

    class << self

      def begin
        new.init_as_prototype_
      end

      private :new
    end  # >>

    # -- as prototype

    def init_as_prototype_
      self
    end

    def root_ACS= p
      @_root_ACS_proc = p
    end

    def to_classesque  # tracking #[#011]
      Home_::CLI_Support_::Prototype_as_Classesque.new self
    end

    # -- as instance (initting)

    def initialize_copy _
      # (nothing yet - but watch this space! be careful)
      NIL_
    end

    def universal_CLI_resources sin, sout, serr, pn_s_a

      @sin = sin ; @sout = sout ; @serr = serr
      @__program_name_string_array = pn_s_a
      NIL_
    end

    def finish

      # do this after any `dup` has been called so that the same CLI
      # *prototype* will not reuse the same ACS instance across its instances.

      # #todo - this is the first of two places where we pass this handler.
      # the second is for any operation when resolved. let's see if we can
      # forego passing it this first time ..

      @_oes_p = method :on_ACS_emission_  # (only do this in 1 place)

      _p = remove_instance_variable :@_root_ACS_proc
      _acs = _p.call( & @_oes_p )
      @_top = Here_::Stack_Frame__::Root.new self, _acs
      self
    end

    # as for `@_top` - see "why linked list" in [#024]

    # -- invocation

    def invoke argv  # *always* result in an exitstatus

      @_arg_st = Callback_::Polymorphic_Stream.via_array argv

      bc = ___bound_call
      if bc
        @__did_emit_error = false
        x = bc.receiver.send bc.method_name, * bc.args, & bc.block
        if @__did_emit_error
          exitstatus_for_ :_component_rejected_request_  # observe [#026]
        else
          Here_::Express_Result___[ x, self ]  # see
          0  # SUCCESS_EXITSTATUS
        end
      else
        @_exitstatus  # e.g syntax error somewhere in this file, missing req's
      end
    end

    def ___bound_call

      if @_arg_st.no_unparsed_exists

        when_no_arguments_  # t1

      elsif _head_token_starts_with_dash

        __when_head_argument_looks_like_option  # t2
      else
        __when_head_argument_looks_like_action
      end
    end

    def when_no_arguments_
      __remote_when Remote_when_[]::No_Arguments.new node_formal_property_, self
    end

    def __when_head_argument_looks_like_option

      if /\A-h|--h(?:e(?:l(?:p)?)?)?/ =~ current_token_
        self._HELP_is_next_step
      else
        _m = "request cannot start with options. (had: \"#{ current_token_ }\")"
        _done_because _m, :argument
      end
    end

    # -- THE LOOP (implement exactly the flowchart of [#014]/figure-1)

    def __when_head_argument_looks_like_action
      begin
        x = ___procure_current_association
        x or break

        x = send WHICH_1___.fetch( x.associationesque_category ), x
        x or break

        if x.loop_again
          redo
        end
        x = x.parse_result
        break
      end while nil
      x
    end

    def ___procure_current_association

      asq = @_top.lookup_straight_then_fuzzy__ current_token_, & @_oes_p
      if ! asq  # t3 (emitted about above)
        _done_because :argument
      end
      asq
    end

    WHICH_1___ = {
      association: :__parse_found_association,
      formal_operation: :__parse_found_operation,
    }

    def __parse_found_association asc

      send WHICH_2___.fetch( asc.model_classifications.category_symbol ), asc
    end

    WHICH_2___ = {
      primitivesque: :___when_assoc_is_not_compound,
      compound: :__parse_found_compound,
    }

    def ___when_assoc_is_not_compound asc  # t4

      _k = asc.model_classifications.category_symbol
      _msg = "\"#{ asc.name.as_slug }\" is not accessed with that syntax (#{_k})"
      _done_because _msg, :argument
    end

    def __parse_found_compound asc

      _qk = ACS_::Interpretation::Touch[ asc, @_top.reader_writer_ ]
      _push _qk, :NonRootCompound
      @_arg_st.advance_one

      # note - if we wanted to we could forestall the `push` until after we
      # know whether or not the below syntax error will occur; but we `push`
      # in these cases regardless so that our "selection stack" gives the
      # fullest context of what we were able to build before we had to stop.

      if @_arg_st.no_unparsed_exists
        Here_::When_::Ended_at_Compound[ self ]  # t6
      elsif _head_token_starts_with_dash
        Here_::When_::Compound_followed_by_Dash[ self ]  # t7
      else
        LOOP_AGAIN___  # t5
      end
    end

    def __parse_found_operation fo

      @_arg_st.advance_one
      _push fo, :Operation

      if @_arg_st.no_unparsed_exists
        _parsed_OK
      else
        ___parse_using_option_parser
      end
    end

    def ___parse_using_option_parser

      _pp = -> asc do
        __build_emission_handler_contextualized_for_atomesque asc
      end

      opc = Here_::Option_Parser_Controller___.new @_fo_frame, & _pp
      op = opc.option_parser___

      argv = @_arg_st.flush_remaining_to_array

      begin
        op.parse! argv
      rescue ::OptionParser::ParseError => e
        ___when_option_parser_parse_error e  # t8
      else
        if opc.ok__
          if argv.length.zero?  # t11
            _parsed_OK
          else
            __when_extra_args argv  # t9
          end
        else
          _done_because :option
          init_exitstatus_for_ :_component_rejected_request_
        end
      end
    end

    def ___when_option_parser_parse_error e
      _done_because e.message, :option
    end

    def __when_extra_args argv
      if 1 < argv.length
        s = 's' ; dd  = ' [..]'
      end
      _msg = "unexpected argument#{ s }: \"#{ argv.first }\"#{ dd }"
      _done_because _msg, :argument
    end

    def __build_emission_handler_contextualized_for_atomesque assoc

      # (we like to hope that this is called IFF the component is sure
      # it's going to emit something.)

      o = Home_.lib_.human::NLP::EN::Contextualization.new( & @_oes_p )

      o.expression_agent = expression_agent
      o.selection_stack = @_fo_frame.formal_operation_.selection_stack
      o.subject_association = assoc
      o.express_subject_association.integratedly

      tr = o.express_trilean.classically_but

      tr.on_failed = -> kns do  # (not "failed to.." but:)
        kns.initial_phrase_conjunction = nil
        kns.inflected_verb = "couldn't #{ kns.verb_lemma.value_x }" ; nil
      end

      # tr.on_neutralled = .. # (try to take away "while" etc one day)

      same = -> asc do
        asc.name.as_human
      end

      o.to_say_selection_stack_item = -> asc do
        if asc.name
          same[ asc ]
        end
      end

      o.to_say_subject_association = same

      o.to_emission_handler
    end

    def _parsed_OK

      # NOTE that we do not pass the real argument stream to parse, but
      # rather only an empty stream. this is because the [#014] premise
      # is that parameters are only ever parsed by the whole tree.
      #
      # were it for [#016] operation-specific parameters, maybe they should
      # have already been parsed by now by the o.p. we could get crazy with
      # the syntax of those, but why.

      _fo = @_fo_frame.formal_operation_

      _pvs = ACS_::Parameter::ValueSource_for_ArgumentStream.the_empty_value_source

      call_oes_p = -> * i_a, & ev_p do
        :error == i_a.first and self._RECONSIDER_readme
          # maybe use whenner insted of @__did_emit_error and the rest
        handle_ACS_emission_ i_a, & ev_p
      end

      _pp = -> _ do
        call_oes_p
      end

      o = Home_::Invocation_::Procure_bound_call.begin_ _pvs, _fo, & _pp

      whenner = nil

      o.on_unavailable_ = -> * i_a, & ev_p do

        whenner ||= Here_::When_::Unavailable[ self ]
        whenner.on_unavailable__ i_a, & ev_p
      end

      bc = o.execute

      if bc
        Result___.new bc
      else
        whenner.finish
        bc
      end
    end

    def _push x, const
      _cls = Here_::Stack_Frame__.const_get const, false
      frame = _cls.new @_top, x
      if frame.wraps_operation
        @_fo_frame = frame
      end
      @_top = frame ; nil
    end

    def operation_frame_
      @_fo_frame
    end

    def top_frame_
      @_top
    end

    def _head_token_starts_with_dash  # assume non-empty stream
      DASH_BYTE_ == @_arg_st.current_token.getbyte( 0 )
    end

    def current_token_
      @_arg_st.current_token
    end

    # -- finishing behavior & loop control constants

    def _done_because msg=nil, bc_sym

      init_exitstatus_for_ :_parse_error_
      if msg
        line_yielder << msg
      end
      express_stack_invite_( * ( [ :because, bc_sym ] if bc_sym ) )
      STOP_PARSING_
    end

    def __remote_when whn

      # [br]'s "when's" are shaped like a bc & always result in an exitstatus.

      _x = whn.receiver.send whn.method_name, * whn.args, & whn.block
      init_exitstatus_ _x
      STOP_PARSING_
    end

    module LOOP_AGAIN___ ; class << self
      def loop_again
        true
      end
    end ; end

    class Result___

      def initialize x
        @parse_result = x
      end

      attr_reader(
        :parse_result,
      )

      def loop_again
        false
      end
    end

    # -- as `invocation_expression`

    def express_stack_invite_ * x_a

      @_for_what_kn = nil

      if x_a.length.nonzero?
        st = Callback_::Polymorphic_Stream.via_array x_a
        begin
          send :"__invite_will_express__#{ st.gets_one }__", st
        end until st.no_unparsed_exists
      end

      kn = remove_instance_variable :@_for_what_kn
      if kn
        for_what = kn.value_x
      else
        for_what = " for help"
      end

      s_a = _expressable_stack_aware_program_name_string_array.dup
      s_a.push HELP_OPTION__

      express_ do |y|
        y << "see #{ code s_a.join SPACE_ }#{ for_what }"
      end
      NIL_
    end

    alias_method :express_invite_to_general_help,  # [br]
      :express_stack_invite_

    def __invite_will_express__because__ st

      sym = st.gets_one
      if sym
        use_x = " for more about #{ sym }s"  # meh
      end

      @_for_what_kn = Callback_::Known_Known[ use_x ] ; nil
    end

    def __invite_will_express__for_more__ _

      @_for_what_kn = Callback_::Known_Known[ " for more." ] ; nil
    end

    def expression_strategy_for_property prp  # for expag
      if Home_.lib_.fields::Is_required[ prp ]
        :render_property_as_argument
      else
        self._K
      end
    end

    def express_primary_usage_line

      parts = _expressable_stack_aware_program_name_string_array.dup
      ___express_arguments_into parts
      parts.push ELLIPSIS_PART_

      express_ do |y|
        y << "usage: #{ code parts.join SPACE_ }"
      end
      NIL_
    end

    def ___express_arguments_into parts
      expag = expression_agent
      prp = node_formal_property_
        expag.calculate do
          parts.push parameter_in_black_and_white prp
        end
      NIL_
    end

    def _expressable_stack_aware_program_name_string_array
      @_top.expressible_program_name_string_array_
    end

    def build_expressible_program_name_string_array__

      s_a = @__program_name_string_array.dup
      s_a[ 0 ] = ::File.basename s_a.first
      s_a
    end

    def express & p
      line_yielder << expression_agent.calculate( & p )
      NIL_
    end

    def express_ & y_p
      expression_agent.calculate line_yielder, & y_p
      NIL_
    end

    def node_formal_property_
      Here_::When_Support_::Node_formal_property[]
    end

    # -- emission handing support

    def on_ACS_emission_ * i_a, & ev_p
      handle_ACS_emission_ i_a, & ev_p
    end

    def handle_ACS_emission_ i_a, & ev_p

      if :error == i_a.first
        @__did_emit_error = true
      end

      @___HE ||= ___build_handler_expresser
      @___HE.handle i_a, & ev_p  # result is unreliable
    end

    def ___build_handler_expresser

      # (was #[#ca-046] but now we "do it right":)
      he = expression_agent.begin_handler_expresser
      he.downstream_yielder = line_yielder
      he
    end

   # -- expression mechanisms

    def expression_agent
      @___expag ||= Remote_CLI_lib_[]::Expression_Agent.new self
    end

    def line_yielder
      @___line_yielder ||= ___build_line_yielder
    end

    def ___build_line_yielder
      serr = @serr
      ::Enumerator::Yielder.new do | s |
        serr.puts s
      end
    end

    attr_reader(
      :sout,
    )

    # -- exit statii

    def init_exitstatus_for_ k
      init_exitstatus_ exitstatus_for_ k
    end

    def init_exitstatus_ d
      @_exitstatus = d ; nil
    end

    def exitstatus_for_ _sym_
      Exit_status_for___[ _sym_ ]
    end

    Exit_status_for___ = -> do
      _OFFSET = 6  # generic erorr (5) + 1
      p = -> kk do
        a = %i(
          _parse_error_
          _component_rejected_request_
          missing_required_parameters
        )
        p = -> k do
          # (we would cache but it's niCLI)
          d = a.index k
          if d
            d + _OFFSET
          end
        end
        p[ kk ]
      end
      -> sym do
        p[ sym ]
      end
    end.call

    # --

    Remote_when_ = -> do
      Remote_CLI_lib_[]::When
    end

    Remote_CLI_lib_ = Lazy_.call do
      Home_.lib_.brazen::CLI_Support
    end

    DASH_ = '-'
    DASH_BYTE_ = DASH_.getbyte 0
    ELLIPSIS_PART_ = '[..]'
    HELP_OPTION__ = '-h'
    Here_ = self
    STOP_PARSING_ = false
    UNDERSCORE_ = '_'
  end
end
