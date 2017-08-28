module Skylab::Basic

  class Function::BoundCall_of_Operation_via_Proc < Common_::MagneticBySimpleModel

    # -

      # (legacy nodes in [#052], but also use this identifer for tracking.)

      #   - this is the (at writing) newest such thing. it's a fresh take
      #     to comport with the [ze] style of microservice diaspora.
      #
      #   - for reference, subject is based off of [ze]'s (or [br]'s)
      #     `BoundCall_of_Operation_with_Definition` (but is now
      #     unrecognizable when held up against that).
      #
      #   - if your proc takes as least one parameter, the endmost parameter
      #     will be used to pass a structure that wraps the "microservice
      #     invocation" (through which can be reached the "invocation
      #     resources" like maybe the filesystem, etc).
      #
      #   - the (any) N-1 other formal parameters in your list will be
      #     interpreted as being required parameters. if you want optionals
      #     you've gotta use a class.
      #
      #   - the (any) N-1 other formal parameters in your list must not
      #     specify defaults (in the way you do for function/method
      #     parameters in the platform language). if you want defaults
      #     you've gotta use a class.
      #
      #   - currently the only coverage of this is by [cu]. one day
      #     all occurrences of the equivalent thing in legacy [br] will
      #     be replaced by this and we will point our native tests at this #open :[#036]

      def initialize
        super  # hi.
      end

      attr_writer(
        :invocation_or_resources,
        :invocation_stack_top_name_symbol,  # will probably build out eventually
        :proc,
      )

      def execute
        __init_parameter_name_symbols_and_whether_it_takes_a_block
        __init_whether_it_takes_the_stackish
        if __procure_arguments_hash_by_normalizing
          __flush_bound_call
        end
      end

      def __flush_bound_call

        args = []
        h = remove_instance_variable :@__parameter_values_hash
        remove_instance_variable( :@_parameter_name_symbols ).each do |sym|
          args.push h.fetch sym
        end

        if remove_instance_variable :@__it_does_take_a_block
          p = _invocation_resources.listener
        end

        the_proc = remove_instance_variable :@proc

        if remove_instance_variable :@__it_does_take_a_stack
          args.push __build_stackish
        end

        Common_::BoundCall[ args, the_proc, :call, & p ]
      end

      def __build_stackish
        a = [
          @invocation_or_resources.value,
          @invocation_stack_top_name_symbol,
        ]
        case @invocation_or_resources.name_symbol
        when :_invocation_PL_
          FrameWhenInvo___.new( * a )
        when :_invocation_resources_PL_
          self._COVER_ME__easy__
        else ; never
        end
      end

      FrameWhenInvo___ = ::Struct.new(
        :microservice_invocation,
        :invocation_stack_top_name_symbol,
      )

      def __procure_arguments_hash_by_normalizing

        _fo_st = Stream_.call @_parameter_name_symbols do |name_sym|
          YuckStubbyFakeAssociation___[ name_sym ]
        end

        invo_rsx = _invocation_resources

        _arg_scn = invo_rsx.argument_scanner
        _listener = invo_rsx.listener  # probably comes from above

        h = {}

        _ok = MTk_[]::Normalization.call_by do |o|

          o.hash_store = h
          o.argument_scanner = _arg_scn
          o.association_stream_newschool = _fo_st
          o.listener = _listener
        end

        if _ok
          @__parameter_values_hash = h ; ACHIEVED_
        end
      end

      def _invocation_resources  # 2x
        send( @_invocation_resources ||= :__invocation_resources_initially )
      end

      def __invocation_resources_initially
        o = @invocation_or_resources.value
        _x = case @invocation_or_resources.name_symbol
        when :_invocation_PL_ ; o.invocation_resources
        when :_invocation_resources_PL_ ; self._COVER_ME__already_done__ ; o
        else ; never
        end
        @___invocation_resources = _x
        send( @_invocation_resources = :___invocation_resources )
      end

      def ___invocation_resources
        @___invocation_resources
      end

      def __init_whether_it_takes_the_stackish

        name_sym_a = @_parameter_name_symbols
        if name_sym_a.length.nonzero?
          _ = name_sym_a.pop
          _ == :stackish || self._OK__this_was_temporary__
          _yes = true
        end
        @__it_does_take_a_stack = _yes ; nil
      end

      def __init_parameter_name_symbols_and_whether_it_takes_a_block

        name_sym_a = [] ; takes_block = nil

        @proc.parameters.each do |(opt_req_block, name_sym)|
          case opt_req_block
          when :req
            name_sym_a.push name_sym
          when :block
            takes_block = true
          else
            self._COVER_ME__every_parameter_of_the_proc_must_required__
          end
        end

        @__it_does_take_a_block = takes_block
        @_parameter_name_symbols = name_sym_a ; nil
      end
    # -

    # ==

    YuckStubbyFakeAssociation___ = ::Struct.new :name_symbol do

      def is_required
        TRUE
      end

      def default_by
        NOTHING_
      end

      def normalize_by
        NOTHING_
      end

      def store_by
        NOTHING_
      end

      def do_guard_against_clobber
        TRUE
      end

      def argument_is_optional
        NOTHING_
      end

      def is_glob
        NOTHING_
      end

      def is_flag
        NOTHING_
      end
    end

    # ==

      # (reminder: [ta], [cu], [sn])

      Brazen_ = ::Skylab::Brazen  # assumed

      class Unbound_via_Function  # (legacy notes in [#052])

        include Brazen_.actionesque_defaults::Unbound_Methods

        def initialize p, const_sym, source, parent_unbound

          @name_s = "#{ source.name }#{ CONST_SEP_ }#{ const_sym }"
          @_p = p
          @_parent_unbound = parent_unbound
        end

        def silo_module
          pu = @_parent_unbound
          if pu
            pu.silo_module
          end
        end

        def build_unordered_index_stream & _

          Common_::Stream.via_item self
        end

        def name_function
          @___nf ||= Brazen_::Actionesque::Name::Build_name_function[ self ]
        end

        def name
          @name_s
        end

        def new k, & oes_p

          @__cx ||= Signature_Classifications___.new( @_p )

          As_Bound_Action___.new @__cx, k, self, & oes_p
        end

        attr_reader(
          :_p,
        )
      end

    # ==

      class Signature_Classifications___

        def initialize p

          a_a = p.parameters

          @accepts_block = false
          @accepts_support_argument = false

          if a_a.length.nonzero?

            if :block == a_a.last.first
              @accepts_block = true
              a_a.pop
            end

            if a_a.length.nonzero?
              send :"__#{ a_a.last.first }__", a_a
            end
          end

          @business_parameters = a_a.freeze
        end

        attr_reader :accepts_block, :accepts_support_argument,
          :business_parameters

        def members
          self.class.instance_methods false
        end

        def __req__ a_a
          a_a.pop
          @accepts_support_argument = true
          NIL_
        end
      end

    # ==

      class As_Bound_Action___

        include Brazen_.actionesque_defaults::Bound_Methods

        def initialize cx, k, unbound, & oes_p

          @kernel = k
          @on_event_selectively = oes_p
          @signature_classifications = cx
          @unbound = unbound
        end

        attr_reader :unbound, :on_event_selectively

        def accept_parent_node _
        end

        def name
          @unbound.name_function
        end

        def formal_properties
          _parameter_box
        end

        def _parameter_box
          @pbx ||= __build_parameter_box
        end

        def __build_parameter_box

          bx = Common_::Stream::MutableBox.via_box_members [], {}

          @signature_classifications.
              business_parameters.each do | opt_req_rest, name_symbol |

            case opt_req_rest
            when :req
              argument_arity = :one
              parameter_arity = :one
            when :opt
              argument_arity = :one
              parameter_arity = :zero_or_one
            when :rest
              argument_arity = :zero_or_more
              parameter_arity = :zero_or_one # or not ..
            else
              raise ::NoMethodError, opt_req_rest
            end

            _prp = ::Skylab::Brazen::Modelesque::Entity::Property.new_by do

              @argument_arity = argument_arity
              @name = Common_::Name.via_variegated_symbol name_symbol
              @parameter_arity = parameter_arity
            end

            bx.add name_symbol, _prp
          end

          bx
        end

        def bound_call_against_argument_scanner st  # #hook-out

          arglist = []

          h = __hash_via_flushing_probably_argument_scanner st

          miss_prp_a = nil

          @signature_classifications.business_parameters.each do | orr, name_sym |

            x = h.delete name_sym

            if :req == orr && x.nil?

              _prp = Home_::MinimalProperty.
                via_variegated_symbol name_sym

              miss_prp_a ||= []
              miss_prp_a.push _prp
            else
              arglist.push x
            end
          end

          if h.length.nonzero?
            extra_sym_a = h.keys
          end

          if extra_sym_a

            __bc_when_extra extra_sym_a

          elsif miss_prp_a

            __bc_when_miss miss_prp_a
          else

            __bc_via_arglist arglist
          end
        end

        def __hash_via_flushing_probably_argument_scanner st

          h = {}
          while st.unparsed_exists
            h[ st.gets_one ] = if st.unparsed_exists
              st.gets_one
            end
          end
          h
        end

        def __bc_when_extra extra_sym_a

          _maybe_send_event :error do
            __build_when_extra_arguments_event extra_sym_a
          end

          UNABLE_  # the result of the above is unreliable  # #here
        end

        def __build_when_extra_arguments_event extra_sym_a

          # used to need #[#co-070.2] `new`, but no longer #tombstone-A

          _ev = Home_.lib_.fields::Events::Extra.with(
            :unrecognized_tokens, extra_sym_a,
            :noun_lemma, "argument",
            :adjective_lemma, "unexpected",
          )

          _sign_event _ev
        end

        def __bc_when_miss miss_prp_a

          _maybe_send_event :error do
            __build_missing_arguments_event miss_prp_a
          end

          UNABLE_  # the result of the above is unreliable, same as #here
        end

        # (tracked with :[#fi-037.5.H])

        def __build_missing_arguments_event miss_prp_a

          self._COVER_ME__easy_just_refactor__
          # the below shoud look like Yadda.with :reasons, miss_prp_a, :noun_lemma, 'argument'
          # if you really need it, see #tombstone-B

          _ev = Home_.lib_.fields::Events::Missing.via miss_prp_a, 'argument'

          _sign_event _ev
        end

        def __bc_via_arglist arglist

          cx = @signature_classifications

          if cx.accepts_support_argument

            arglist.push self  # #mechanic-1
          end

          if cx.accepts_block

            p = @on_event_selectively
          end

          Common_::BoundCall[ arglist, @unbound._p, :call, & p ]
        end

        def _maybe_send_event * i_a, & ev_p

          @on_event_selectively[ * i_a, & ev_p ]
        end

        def _sign_event ev
          _nf = @unbound.name_function
          Common_::Event::Via_signature[ _nf, ev ]
        end
      end

    # ==

    MTk_ = -> do
      ::Skylab::Zerk::MicroserviceToolkit
    end

    # ==
    # ==
  end
end
# :#tombstone-B - temporary
# :#tombstone-A - we used to use a thing we no longer use
