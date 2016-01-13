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

    class << self

      def begin
        new.init_as_prototype_
      end

      private :new
    end  # >>

    # -- processing events

    def handle_ACS_emission_ * i_a, & ev_p
      if :expression == i_a.fetch( 1 )
        ___express_expression i_a, & ev_p
      else
        self._K
      end
    end

    def _USE_ME__express_expression i_a, & ev_p

      expression_agent.calculate line_yielder, & ev_p
    end

    # --  hook-outs for [br] "when" nodes

    # ~ officious

    def express_primary_usage_line

      parts = _expressable_program_name_string_array.dup
      __express_arguments_into parts
      parts.push ELLIPSIS_PART___

      y = line_yielder
      expression_agent.calculate do
        y << "usage: #{ code parts.join SPACE_ }"
      end
      NIL_
    end

    def __express_arguments_into parts

      expag = expression_agent
      prp = _action_property
        expag.calculate do
          parts.push parameter_in_black_and_white prp
        end
      NIL_
    end

    def express_invite_to_general_help * x_a

      if x_a.length.nonzero?
        o = { because: nil }
        Home_.lib_.basic::Hash.write_even_iambic_subset_into_via o, x_a
        s = o[ :because ]
        if s
          for_what = "to see available #{ s }s"
        end
      end

      for_what ||= "for help"

      s_a = _expressable_program_name_string_array.dup
      s_a.push HELP_OPTION__

      y = line_yielder
      expression_agent.calculate do
        y << "use #{ code s_a.join SPACE_ } #{ for_what }"
      end ; NIL_
    end

    # ~ other hook-outs for [br] "when" nodes

    def express & p
      _exp = expression_agent
      _s = _exp.calculate( & p )
      line_yielder << _s
      NIL_
    end

    def expression_strategy_for_property prp  # for expag

      if Home_.lib_.fields::Is_required[ prp ]
        :render_property_as_argument
      else
        self._K
      end
    end

    # -- invocation

    def invoke argv
      @_arg_st = Callback_::Polymorphic_Stream.via_array argv
      bc = ___bound_call
      if bc
        bc.receiver.send bc.method_name, * bc.args, & bc.block
      else
        @_exitstatus
      end
    end

    def ___bound_call

      if @_arg_st.no_unparsed_exists

        when_no_arguments_

      elsif DASH_BYTE_ == @_arg_st.current_token.getbyte( 0 )

        __when_head_argument_looks_like_option
      else
        __when_head_argument_looks_like_action
      end
    end

    def when_no_arguments_
      _when::No_Arguments.new _action_property, self
    end

    def __when_head_argument_looks_like_option

      s = @_arg_st.current_token
      if HELP_OPTION__ == s || /\A--h(?:e(?:l(?:p)?)?)?\z/ =~ s
        __when_help
      else
        ___when_unrecognized_option
      end
    end

    def ___when_unrecognized_option

      _msg = "invalid option: #{ @_arg_st.current_token }"
      _when::Parse_Error.new _msg, self
    end

    def __when_help

      _when::Help::For_Branch.new NIL_, self, self
    end

    # -- as instance (before invoke)

    def initialize_copy _
      # (nothing yet.)
      NIL_
    end

    def universal_CLI_resources sin, sout, serr, pn_s_a

      @sin = sin ; @sout = sout ; @serr = serr
      @program_name_string_array = pn_s_a
      NIL_
    end

    def finish

      # do this after any `dup` has been called so that the same CLI
      # *prototype* will not reuse the same ACS instance across its instances.

      _p = remove_instance_variable :@_root_ACS_proc

      _handle_ACS_emission = method :handle_ACS_emission_

      @ACS_ = _p.call( & _handle_ACS_emission )

      self
    end

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

    # -- support

    def _action_property
      _lib.standard_branch_property_box.fetch :action
    end

    def _expressable_program_name_string_array
      @___pn_s_a ||= ___build_expressable_program_name_string_array
    end

    def ___build_expressable_program_name_string_array
      parts = @program_name_string_array.dup
      parts[ 0 ] = ::File.basename parts.first
      parts.freeze
    end

    def expression_agent
      @___expag ||= _lib::Expression_Agent.new self
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

    def _when
      _lib::When
    end

    def _lib
      Home_.lib_.brazen::CLI_Support
    end

    DASH_BYTE_ = '-'.getbyte 0
    ELLIPSIS_PART___ = '[..]'
    HELP_OPTION__ = '-h'
  end
end
