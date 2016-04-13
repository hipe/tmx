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
      @invite = nil
      @when_head_argument_looks_like_option = nil
      self
    end

    attr_writer(
      :compound_custom_sections,
      :compound_usage_strings,
      :invite,
      :operation_usage_string,  # #todo
      :when_head_argument_looks_like_option,
    )

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

      begin
        bc = ___bound_call_step
        bc or break
        if true == bc
          redo  # EEK experiment [#my-009]
        end
        break
      end while nil

      bc
    end

    def ___bound_call_step

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

      p = @when_head_argument_looks_like_option
      if p
        p[ * ( self if 1 == p.arity ) ]
      else
        ___when_head_argument_looks_like_option_normally
      end
    end

    def ___when_head_argument_looks_like_option_normally

      md = head_token_starting_with_dash_match_help_request
      if md
        when_head_argument_looks_like_help md
      else
        _ = "request cannot start with options. (had: \"#{ current_token }\")"
        _done_because _, :argument
      end
    end

    # -- THE LOOP (implement exactly the flowchart of [#014]/figure-1)

    def __when_head_argument_looks_like_action
      begin
        x = ___procure_current_navigational_formal_node
        x or break

        x = send PARSE___.fetch( Formal_node_3_category_[ x ] ), x
        x or break

        if x.loop_again
          redo
        end
        x = x.parse_result
        break
      end while nil
      x
    end

    PARSE___ = {
      compound: :__parse_found_compound,
      formal_operation: :__parse_found_operation,
    }

    def ___procure_current_navigational_formal_node

      fn = @_top.lookup_formal_node__ current_token, :navigational, & @_oes_p
      if ! fn  # probably the above emitted t3 or t4
        _done_because :argument
      end
      fn
    end

    def __parse_found_compound asc

      @_top = @_top.attach_compound_frame_via_association_ asc  # #push
      @_fo_frame = nil
      @_arg_st.advance_one

      # note - if we wanted to we could forestall the `push` until after we
      # know whether or not the below syntax error will occur; but we `push`
      # in these cases regardless so that our "selection stack" gives the
      # fullest context of what we were able to build before we had to stop.

      if @_arg_st.no_unparsed_exists

        Here_::When_::Ended_at_Compound[ self ]  # t6

      elsif _head_token_starts_with_dash

        md = head_token_starting_with_dash_match_help_request
        if md
          when_head_argument_looks_like_help md
        else
          Here_::When_::Compound_followed_by_Dash[ self ]  # t7
        end
      else
        LOOP_AGAIN___  # t5
      end
    end

    def head_token_starting_with_dash_match_help_request
      Help_rx___[].match current_token
    end

    def when_head_argument_looks_like_help md
      @_arg_st.advance_one
      Here_::When_Help_[ md, self ]
      STOP_PARSING_
    end

    def __parse_found_operation fo

      fo_frame = @_top.attach_operation_frame_via_formal_operation_ fo

      @_fo_frame = fo_frame  # redundant ivar w/ below for sanity
      @_operation_syntax = fo_frame.operation_syntax_
      @_top = fo_frame  # #push

      @_arg_st.advance_one

      @__bespoke_values_box = nil  # ivar must be set

      kp = __maybe_parse_opts
      kp &&= __maybe_parse_args
      kp && _parsed_OK  # t11
    end

    # --

    def __maybe_parse_opts

      # if the argument stream is empty, avoid the heavy lift of building o.p

      if @_arg_st.no_unparsed_exists  # then is empty
        KEEP_PARSING_
      else
        ___parse_opts
      end
    end

    def ___parse_opts

      @_operation_syntax.parse_opts__ _ARGS_AS_ARGV, self, & _parse_pp
    end

    def when_via_option_parser_parse_error__ e  # t8
      _done_because e.message, :option
    end

    def when_via_option_parser_component_rejected_request__
      _done_because :_component_rejected_request_, :option
    end

    def when_via_option_parser_help_was_requested__ any_s

      _ARGS_AS_STREAM  # convert back, because help wants us in that state eew
      _FAKE_MATCHDATA = { eql: any_s }  # ..
      Here_::When_Help_[ _FAKE_MATCHDATA, self ]
      STOP_PARSING_
    end

    # --

    def __maybe_parse_args

      os = @_operation_syntax

      if os.has_formal_arguments__
        _ARGS_AS_ARGV  # convert if necessary
        _argv = remove_instance_variable :@_argv  # this is the end of the line
        _ok = os.parse_arguments__ _argv, self, & _parse_pp
        _ok
      else
        _ARGS_AS_STREAM  # convert it back, in case o.p converted it..
        if @_arg_st.no_unparsed_exists
          remove_instance_variable :@_arg_st
          ACHIEVED_
        else
          __when_extra_args_native
        end
      end
    end

    def when_via_argument_parser_component_rejected_request__

      _done_because :_component_rejected_request_, :argument
    end

    def when_via_argument_parser_extra__ ev

      _when_extra_arg ev.x
    end

    def __when_extra_args_native  # t9

      s = @_arg_st.gets_one

      _yes = ! @_arg_st.no_unparsed_exists

      _when_extra_arg s, _yes
    end

    def when_via_argument_parser_missing__ ev

      _moniker = Remote_CLI_lib_[]::Syntax_Assembly.
        render_as_argument_uninflected_for_arity ev.property

      _msg = expression_agent.calculate do
        "missing required argument #{ highlight _moniker }"
      end

      _done_because _msg, :missing_required_parameters, :argument
    end

    def _when_extra_arg extra_s, has_more=false

      if has_more
        ellipsis = ' [..]'
        s = 's'
      end

      _msg = "unexpected argument#{ s }: \"#{ extra_s }\"#{ ellipsis }"
      _done_because _msg, :argument
    end

    def store_floaty_value_of_bespoke__ qkn  # o.s
      _ = ( @__bespoke_values_box ||= Callback_::Box.new )  # :"floaty structure"
      _.add qkn.name_symbol, qkn
      NIL_
    end

    # --

    # both stdlib o.p and our "classic" argument parser require a plain old
    # array as input as opposed to the (superior) polymorphic stream we use
    # internally. whether or not we engage one, the other, none or both o.p
    # and args parsing depends on both formal syntax and actual arguments.
    # so the "easiest" way to avoid extraneous flip-flops between array and
    # stream is with this below nastiness which we hate, which is why it is
    # in shoutcase (:#here):

    def _ARGS_AS_STREAM
      @_arg_st ||= Callback_::Polymorphic_Stream.via_array( remove_instance_variable :@_argv )
    end

    def _ARGS_AS_ARGV
      @_argv ||= remove_instance_variable( :@_arg_st ).flush_remaining_to_array
    end

    def _parse_pp
      @___ppp ||= method :___build_handler_contextualized_for_primitivesque
    end

    # --

    def ___build_handler_contextualized_for_primitivesque assoc

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

      # way downstream, somehow a session will arrange one parameter value
      # for every stated parameter (more or less) so that it can call the
      # operation implementation (imagine a proc). for those values that live
      # in the ACS tree ("appropriated"), this is managed elsewhere. but for
      # those values that do not (because they are "bespoke"), here is where
      # we pass them:

      bx = remove_instance_variable :@__bespoke_values_box

      if bx
        _pvs = Here_::Argument_Parser_Controller_::Parameter_Value_Source_via_Box.new bx
      else
        _pvs = ACS_::Parameter::ValueSource_for_ArgumentStream.the_empty_value_source
        # (nothing more to add. everything went from options into the tree.)
      end

      _fo = @_fo_frame.formal_operation_

      call_oes_p = -> * i_a, & ev_p do
        :error == i_a.first and self._RECONSIDER_readme
          # maybe use whenner insted of @__did_emit_error and the rest
        handle_ACS_emission_ i_a, & ev_p
      end

      _pp = -> _ do
        call_oes_p
      end

      o = Home_::Invocation_::Procure_bound_call.begin_ _pvs, _fo, & _pp

      _ = @_operation_syntax.existent_operation_index__
      unless _
        self._COVER_ME  # #todo
      end
      o.operation_index = _

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

    def release_selection_stack__
      remove_instance_variable :@_top
    end

    def top_frame  # [my]
      @_top
    end

    def _head_token_starts_with_dash  # assume non-empty stream
      Begins_with_dash_[ @_arg_st.current_token ]
    end

    def current_token
      @_arg_st.current_token
    end

    def release_argument_stream__
      remove_instance_variable :@_arg_st
    end

    def argument_stream
      @_arg_st
    end

    # -- finishing behavior & loop control constants

    def _done_because msg=nil, es_sym=:_parse_error_, bc_sym

      if msg.respond_to? :id2name
        es_sym = msg
        msg = nil
      end

      if msg
        line_yielder << msg
      end

      express_stack_invite_ :because, bc_sym

      init_exitstatus_for_ es_sym

      STOP_PARSING_
    end
    alias_method :done_because, :_done_because

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

      inv = Here_::Invitation___.new x_a, self
      p = @invite
      if p
        s = p[ inv ]
        if s
          line_yielder << s
        end
      else
        inv.express
      end
      NIL_
    end

    alias_method :express_invite_to_general_help,  # [br]
      :express_stack_invite_

    def expression_strategy_for_property prp  # for expag
      if Home_.lib_.fields::Is_required[ prp ]
        :render_property_as_argument
      else
        self._K
      end
    end

    def express_primary_usage_line

      parts = expressable_stack_aware_program_name_string_array_.dup
      ___express_arguments_into parts
      parts.push ELLIPSIS_PART

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

    def expressable_stack_aware_program_name_string_array_
      @_top.expressible_program_name_string_array_
    end

    def build_program_name_string_array_as_root_stack_frame__
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

    def on_event_selectively__
      @_oes_p
    end

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

    def express_section_via__ x_a, & p
      section_expression_.express_section_via x_a, & p
    end

    def section_expression_
      @___SE ||= ___build_SE
    end

    def ___build_SE
      Remote_CLI_lib_[]::Section::Expression.new line_yielder, expression_agent
    end

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
      :compound_custom_sections,
      :compound_usage_strings,
      :operation_usage_string,
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

    # ==

    Exit_status_for___ = -> do
      _OFFSET = 6  # generic erorr (5) + 1
      p = -> kk do
        a = %i(
          _parse_error_
          _component_rejected_request_
          missing_required_parameters
          referent_not_found
          _component_unavailable_
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

    # ==

    Node_ticket_3_category_ = -> nt do  # see #here.

      if :operation == nt.node_ticket_category
        :operation
      else
        nt.association.model_classifications.category_symbol
      end
    end

    Formal_node_3_category_ = -> fn do  # might become :[#ac-034]. also :#here

      if :formal_operation == fn.formal_node_category
        :formal_operation
      else
        fn.model_classifications.category_symbol
      end
    end

    Help_rx___ = Lazy_.call do
      %r(\A(?:-h|--h(?:e(?:l(?:p)?)?)?(?:=(?<eql>.+))?)\z)
    end

    Begins_with_dash_ = -> s do
      DASH_BYTE_ == s.getbyte( 0 )
    end

    Remote_when_ = -> do
      Remote_CLI_lib_[]::When
    end

    Remote_CLI_lib_ = Lazy_.call do
      Home_.lib_.brazen::CLI_Support
    end

    DASH_ = '-'
    DASH_BYTE_ = DASH_.getbyte 0
    ELLIPSIS_PART = '[..]'
    Here_ = self
    SHORT_HELP_OPTION = '-h'
    STOP_PARSING_ = false
    UNDERSCORE_ = '_'
  end
end
