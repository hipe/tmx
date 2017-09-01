module Skylab::Brazen

  CLI = ::Class.new ::Class.new ::Class.new  # see [#002]
  # (the above is an atrocity but it will go away eventually. it's because #here3.)

  class CLI  # (open up scope of old thing, target particular indent. closes #here1)
  class CLI::CLI_for_BeautySalon_PIONEER

    # NOTE
    #
    #   - this is a bleeding edge pioneer
    #
    #   - ultimately it is meant to replace the legacy [br] CLI, which is
    #     why it is being injected into this file.
    #
    #   - its injection here is abrubt because we need it now for a
    #     several-tangets-deep quest chain
    #
    #   - [ze] niCLI is too complicated for us - it presupposes [acs] etc
    #
    #   - [tmx] CLI is the main mentor for this, and [sn] (which has no CLI yet)

    class << self
      alias_method :begin_by, :new
      undef_method :new
    end  # >>

    # -

      # -- strange interface because:
      #   - there is a standard way to invoke CLI: `CLI.new( [ 5 things ] ).execute`
      #   - composition not inheritance
      #   - this is similar to [#ze-003]

      def initialize

        # (ick/meh)
        if ! CLI.const_defined? :UI_
          o = CLI
          o.const_set :Zerk_, Zerk_lib_[]
          o.const_set :MTk_, Zerk_::MicroserviceToolkit
          require 'no-dependencies-zerk'
          o.const_set :UI_, ::NoDependenciesZerk
        end

        yield self
        @ORIG_OPERATOR_BRANCH = @operator_branch  # THE WORST
        @_has_stack = false
      end

      attr_writer(
        :application_module,
        :operator_branch,
      )

      def new a, i, o, e, pns_a

        @expression_agent = :__expression_agent_defaultly

        if block_given?
          yield self  # [bs] (tests)
        end

        # --

        # this is fun and goofy and awful - because of our faustian bargain
        # that everything is a prototype and not a class, you don't get a
        # fresh instance for every invocation under your tests YIKES ..

        if @_has_stack
          @operator_branch = @ORIG_OPERATOR_BRANCH  # THE WORST
          remove_instance_variable :@omni
          remove_instance_variable :@stack
          @_has_stack = false
        end

        # ==

        @ARGV = a
        @program_name_string_array = pns_a

        @stderr = e
        @stdin = i
        @stdout = o

        self
      end

      def expression_agent_by= p
        @expression_agent = :__expression_agent_via_proc_initially
        @__expression_agent_proc = p
      end

      def filesystem= x
        @filesystem = :__read_filesystem
        @__filesystem = x
      end

      def redefine
        Resources_HOT_NEW_TAKE___.define do |o|
          yield o
          o.receive_error_channel_by = method :_receive_error_channel
          o.argument_scanner = @args
          o.__stdin_stdout_stderr_ @stdin, @stdout, @stderr
          o.filesystem_by = method :filesystem
        end
      end

      # --

      def execute  # result in exitstatus

        @listener = method :__receive_emission
        __init_argument_scanner_via_listener
        _init_omni_branch_for :_hello_1_BR_, @operator_branch

        @_exitstatus = 0
        bc = __flush_to_bound_call_of_operator
        if bc
          x = bc.receiver.send bc.method_name, * bc.args, & bc.block
          if ! x.nil?
            Zerk_::CLI::ExpressResult[ x, self ]
          end
        elsif ! bc.nil?
          _maybe_increase_errorlevel GENERIC_ERROR_EXITSTATUS
        end
        @_exitstatus
      end

      def __flush_to_bound_call_of_operator

        lu = _process_any_primaries_and_lookup_next_operator
        lu and __bound_call_via_operator lu
      end

      def __bound_call_via_operator lu

        _ref = lu.mixed_business_value

        _ref.bound_call_of_operator_by do |o|

          o.operator_via_branch_by = -> mag do
            __operator_via_branch mag  # hi.
          end

          o.remote_invocation_resources_by = -> op do
            p = remove_instance_variable :@__inject_resources
            if p
              irsx = p[ op, self ]
              # NASTY ##maybe1 - the current top operator is certainly liable
              # to render its own help screen, and if it does its any custom
              # expag is what it should get when it renders. yes do #maybel
              __CHANGE_expression_agent irsx.expression_agent
              irsx
            else
              self
            end
          end

          o.customize_normalization_by = -> n11n do
            n11n.be_fuzzy
          end

          o.receive_operation_module_by = method :__receive_operation_module

          o.receive_operation_by = method :__receive_operation

          o.inject_definitions_by = method :__inject_modality_specific_definitions
        end
      end

      def __operator_via_branch mag

        # when parsing at a non-root branch node, CLI (unlike API) needs to
        # inject the help primary and react appropriately if it's invoked.
        #
        # do exactly like [#pl-011.4] but try to re-use our root-level
        # parsing pipeine instead.

        ob = mag.release_operator_branch

        # NOTE see ##maybe1
        remove_instance_variable :@operator_branch
        @operator_branch = ob

        _init_omni_branch_for :_hello_2_BR_, ob

        _process_any_primaries_and_lookup_next_operator
      end

      def _process_any_primaries_and_lookup_next_operator

        # here's the essence of CLI parsing (in our conception) from a
        # branchy node (root and non-root alike): process the zero-or-more
        # non-primaries and then one operator.
        #
        #   - if you never get to an operator, there's nothing more to do.
        #
        #   - any of the zero or more primaries that is processed can have
        #     arbitrary side-effects, and can effectively end the invocation.
        #
        #   - note that any primaries positioned after the any leftmost
        #     operator will not get parsed here.
        #
        # an imaginary example:
        #
        #     my-app -v some-guy -quiet -x action -h
        #            ^^ ^^^^^^^^
        #            pp oooooooo
        #
        #                        ^^^^^^ ^^ ^^^^^^
        #                        oooooo oo pppppp

        args = @args ; omni = @omni
        begin

          # if scanner empty, end of the line. done.
          if args.no_unparsed_exists
            Zerk_::ArgumentScanner::When::No_arguments[ omni ]
            break
          end

          # if head looks like primary, try parse and repeat.
          if args.scan_primary_symbol_softly
            _kp = omni.process_primary_at_head
            _kp ? redo : break
          end

          # if head looks like operator:
          if args.scan_operator_symbol_softly
            op_found = omni.flush_to_lookup_operator
            # (whether it succeeded or fail, we get off here.)
            break
          end

          # head looks like neither primary nor operator. whine and done
          args.when_malformed_primary_or_operator
          break
        end while above
        op_found
      end

      def __receive_operation op

        if ! @_has_stack
          @stack = []
          @_has_stack = true
        end

        @stack.push StackFrame___.new(
          op,
          @args.current_operator_symbol,
        )
        NIL
      end

      StackFrame___ = ::Struct.new(
        :operation,
        :name_symbol,
      )

      def __inject_modality_specific_definitions o  # association stream controller, from #spot1.1

        p = remove_instance_variable :@__inject_and_deinject
        if p
          p[ o ]
        end
        _help_asc = __build_help_association_bound_to_self
        o.inject_association _help_asc
        NIL
      end

      def __receive_operation_module mod
        modz = mod.const_get :Modalities, false
        if modz
          cli_mod = modz.const_get :CLI, false
        end
        if cli_mod
          p1 = cli_mod::Inject_and_deinject_associations
          p2 = cli_mod::Inject_resources
        end
        @__inject_and_deinject = p1
        @__inject_resources = p2
        NIL
      end

      def __build_help_association_bound_to_self

        _proto = Memoized_help_association_prototype___[]

        _proto.redefine do |o|
          o.will_normalize_by( & method( :__receive_help_request ) )
        end
      end

      def __receive_help_request qkn

        # (the listener block that is passed to this *is* `@listener`,
        # but as a proc instead of as a bound method.)

        # observe [#ze-060.3] about this crazy new argument arity EXPERIMENTAL

        if qkn.is_known_known
          x = qkn.value
          if true == x  # [#fi-012.10] explains exactly this crutch
            __express_operation_help
          else
            ::Kernel._OKAY__have_fun__specific_argument_to_help
          end
        else
          # this normalization runs whether or not the flas was passed.
          # don't stop everything just because the flag was not passed.
          qkn  # [bs]:COVERPOINT2.1
        end
      end

      def __express_operation_help

        op = @stack.last.operation
        @_operation_associations = op.instance_variable_get :@_associations_
          # (this is a violation in 2 ways, but it's experimental..)

        _tuple_st = __to_item_normal_tuple_stream_when_operation

        _desc_proc = Desc_proc_via_module__[ op.class ]  # EEW

        _program_name = get_program_name

        _mod = Zerk_::NonInteractiveCLI::Help::ScreenForEndpoint

        _mod.express_into @stderr do |o|

          _same_help o

          o.item_normal_tuple_stream _tuple_st

          o.express_usage_section _program_name

          o.express_description_section _desc_proc

          o.express_items_sections -> prim_sym do

            asc = @_operation_associations.fetch prim_sym
            p = asc.describe_by
            if p
              p
            else
              NOTHING_  # hi.
            end
          end
        end

        STOP_PARSING_
      end

      def __express_help

        shorten_the_description = -> mod do

          -> y do

            countdown = 3
            _use_y = ::Enumerator::Yielder.new do |line|
              y << line
              countdown -= 1
              countdown.zero? and throw :_yikes_001_BR_
            end

            catch :_yikes_001_BR_ do
              mod.describe_into_under _use_y, self
            end
            y
          end
        end

        _mod = Zerk_::NonInteractiveCLI::Help::ScreenForBranch

        _mod.express_into @stderr do |o|

          _same_help o

          o.item_normal_tuple_stream __to_item_normal_tuple_stream

          o.express_usage_section get_program_name

          o.express_description_section Desc_proc_via_module__[ @application_module ]

          o.express_items_sections -> ref do
            mod = ref.dereference_loadable_reference
            if mod.respond_to? :describe_into_under
              shorten_the_description[ mod ]
            else
              -> y do
                y << "«#{ ref.name_symbol.id2name.gsub UNDERSCORE_, DASH_ } has no description [br]»"  # #guillemets
              end
            end
          end

        end
      end

      def _same_help o
        o.expression_agent _VOLATILE_expag_instance
      end

      def __to_item_normal_tuple_stream_when_operation
        # #open [#br-002.5] modality-targeted association classification
        h = @_operation_associations
        Stream_.call h.keys do |k|
          [ :primary, k ]
        end
      end

      def __to_item_normal_tuple_stream
        @operator_branch.to_loadable_reference_stream.map_by do |key_x|
          [ :operator, key_x ]
        end
      end

      # --

      def _init_omni_branch_for inj_sym, ob

        # NOTE - might be overwriting existing omni. see ##maybe1

        @omni = UI_::ParseArguments_via_FeaturesInjections.define do |fi|

          fi.argument_scanner = @args

          fi.add_lazy_operators_injection_by do |o|
            o.operators = ob
            o.injector = inj_sym
          end

          fi.add_primaries_injection PRIMARIES___, self
        end
        NIL
      end

      # (:#maybe1: @operator_branch and @omni are properties of stack frame)

      PRIMARIES___ = {
        help: :__express_help,
      }

      def __init_argument_scanner_via_listener

        @args = UI_::CLI_ArgumentScanner.define do |o|
          o.ARGV = remove_instance_variable :@ARGV
          o.listener = @listener
        end
        NIL
      end

      def __receive_emission *chan, & em_p

        expr = UI_::CLI_Express_via_Emission.define do |o|
          o.emission_proc_and_channel em_p, chan
          o.expression_agent_by = -> { _VOLATILE_expag_instance }
          o.stderr = @stderr
        end

        sct = expr.execute

        if sct && sct.was_error
          _receive_error_channel chan
        end
      end

      def _receive_error_channel _chan
        _maybe_increase_errorlevel GENERIC_ERROR_EXITSTATUS
        @stderr.puts "try '#{ get_program_name } -h'"  # ..
        NIL
      end

      def get_program_name
        buffer = ::File.basename @program_name_string_array.last  # meh
        if @_has_stack
          scn = Scanner_[ @stack ]
          begin
            _frame = scn.gets_one
            buffer << SPACE_
            buffer << _frame.name_symbol.id2name.gsub( UNDERSCORE_, DASH_ )
          end until scn.no_unparsed_exists
        end
        buffer
      end

      # -- for [ze]

      def _maybe_increase_errorlevel d  # #[#002.B]
        if @_exitstatus < d
          @_exitstatus = d
        end
        NIL
      end

      def receive_exitstatus d
        @_exitstatus = d ; nil
      end

      def argument_scanner  # for self..
        @args
      end

      def __CHANGE_expression_agent expag
        @expression_agent = :_expression_agent_via_instance
        @_expression_agent = expag ; nil
      end

      def _VOLATILE_expag_instance
        send @expression_agent
      end

      def expression_agent
        send @expression_agent
      end

      def __expression_agent_via_proc_initially
        _p = remove_instance_variable :@__expression_agent_proc
        @_expression_agent = _p[ self ]
        @expression_agent = :_expression_agent_via_instance
        send @expression_agent
      end

      def _expression_agent_via_instance
        @_expression_agent
      end

      def __expression_agent_defaultly
        ::NoDependenciesZerk::CLI_InterfaceExpressionAgent.instance
      end

      def sout
        @stdout
      end

      def filesystem
        send @filesystem
      end

      def __read_filesystem
        @__filesystem
      end


      attr_reader(
        :listener,
      )

    # -
  end
  end  # :#here1

  class CLI  # (re-open..)

    class << self

      def expose_executables_with_prefix s

          _proc = Zerk_lib_[]::Models::OneOff::
        Definition_for_the_LEGACY_method_called_to_unordered_selection_stream[ s ]
        define_method :to_unordered_selection_stream, _proc
        NIL_
      end

      def expression_agent_instance
        Zerk_lib_[]::CLI::InterfaceExpressionAgent::THE_LEGACY_CLASS.instance
      end

      def pretty_path x
        Zerk_lib_[]::CLI::InterfaceExpressionAgent::THE_LEGACY_CLASS::Pretty_path[ x ]
      end

      def some_screen_width
        79  # :+#idea-kitestring for ncurses maybe
      end
    end  # >>

    # (:#here3:)

    Top_Invocation__ = self

    Branch_Invocation__ = Top_Invocation__.superclass

    Invocation__ = Branch_Invocation__.superclass

    class Top_Invocation__
    private

      def initialize argv, i, o, e, pn_s_a, * x_a  # pn_s_a = program name string array

        @__argv = argv

        if block_given?
          p = yield.method :exitstatus=
        end
        @__write_exitstatus = p

        if x_a.length.zero?
          h = EMPTY_H_
        else
          h = {}
          x_a.each_slice 2 do | k, x |
            h[ k ] = x
          end
        end

        ak = if h.key? :back_kernel
          h.delete :back_kernel
        else
          back_kernel
        end

        if h.length.nonzero?
          self._COVER_ME
        end

        @app_kernel = ak

        @_invite_ev_a = nil

        @mod = ak.module

        @_resource_components = nil

        @resources ||= Resources.new i, o, e, pn_s_a, @mod   # ivar name is #public_API

        # (abstract base class "invocation" has no initialize method)
      end

    public
      def receive_environment x
        _receive_resource :environment, x
      end

      def receive_filesystem x
        _receive_resource :filesystem, x
      end

      def receive_system_conduit x
        _receive_resource :system_conduit, x
      end

      def _receive_resource sym, x
        ( @_resource_components ||= [] ).push sym, x ; nil
      end

      def to_bound_call
        Common_::BoundCall.via_receiver_and_method_name self, :__execute_plus
      end

      def __execute_plus
        x = execute
        if x.respond_to? :bit_length
          @__write_exitstatus[ x ]
        end
        NOTHING_
      end

      def execute

        argv = remove_instance_variable :@__argv

        rsx = @resources

        if rsx._is_finished
          self._REENTRANCY_WAS_ONCE_COVERED_BUT_IS_NO_LONGER
        else
          rsx._finish argv, remove_instance_variable( :@_resource_components )
        end

        init_properties
        init_categorized_properties

        bc = _bound_call_from_parse_parameters

        x = bc.receiver.send bc.method_name, * bc.args, & bc.block

        # experiment -
        if x.respond_to? :emission_value_proc
          x = ___express_result_emission x
        end

        __flush_any_invitations

        if x
          __result_as_top_via_trueish_backstream_result x
        else
          @exitstatus
        end
      end

    private

      def ___express_result_emission em

        # the experimental #emission-as-result can (perhaps) not be processed
        # like other true-ish backstream values because A) it may need to
        # emit invitation events (but how we express those may change..) and
        # B) so far it's the only shpae that wants to control exitstatus..

        # for an emission to be workable as a result from a backstream call,
        # it may need to manage its own expression. in such cases the below
        # result will be false-ish. otherwise for now we assume etc..

        _ = _emission_interpreter.shape_of em.category

        if :CONVENTIONAL_EMISSION_SHAPE == _

          ev = em.emission_value_proc.call
          if ev
            receive_event_on_channel ev, em.category
          end
          # otherwise the emission autonomously expressed itself
        else
          receive_uncategorized_emission em.category, & em.emission_value_proc
        end
        NIL_  # important
      end

      # ~ ( others at top, then the list from [#024] )

      ## ~~ help & invitations

      def __flush_any_invitations

        if _invite_ev_a
          __flush_invitations
        end
      end

      def __flush_invitations

        seen_i_a_h = {}
        seen_general_h = {}

        a = remove_instance_variable :@_invite_ev_a

        a.each do | ev, adapter |

          ev_ = ev.to_event

          if ev_.has_member :invite_to_action
            i_a = ev_.invite_to_action
          end

          if i_a

            seen_i_a_h.fetch i_a do
              ___express_invite_to_particular_action i_a
              seen_i_a_h[ i_a ] = true
            end

          else

            nf = adapter.bound_.name

            if nf
              k_x = nf.as_const
              seen_general_h.fetch k_x do
                seen_general_h[ k_x ] = true
                adapter.express_invite_to_general_help
              end
            else
              # (the top bound node doesn't have a name. do nothing here
              # when invites happen from the top node as #here-2
            end
          end
        end

        NIL_
      end

      def ___express_invite_to_particular_action sym_a

        _ada = _bound_action_via_normal_name sym_a

        _s = _ada._help_syntax_string  # assume if invited then produced

        _express_invite_to _s
      end

      def send_invitation ev
        _receive_invitation ev, self  # at top, you are your own adapter
        NIL_
      end

      def _receive_invitation ev, adapter
        ( @_invite_ev_a ||= [] ).push [ ev, adapter ]
        NIL_
      end

      def _invite_ev_a
        @_invite_ev_a
      end

      ## ~~ exitstatus & result handling

      def __result_as_top_via_trueish_backstream_result x

        if ACHIEVED_ == x  # covered
          SUCCESS_EXITSTATUS
        elsif x.respond_to? :bit_length  # covered
          x
        elsif x.respond_to? :id2name  # covered by [cu]
          x
        elsif x.respond_to? :ascii_only?  # visually by [tm] paths
          @resources.sout.puts x
          SUCCESS_EXITSTATUS
        else
          o = Home_::CLI_Support::Express_Mixed.new
          o.expression_agent = @adapter.expression_agent
          o.mixed_non_primitive_value = x
          o.serr = @resources.serr
          o.sout = @resources.sout
          o.execute
        end
      end

      ## ~~ actionability (near "navigation of the reactive model")

      def action_adapter
        NIL_
      end

      def bound_
        @___bound_kernel ||= __build_bound_kernel
      end

      def __build_bound_kernel
        Bound_Kernel___.new( @app_kernel, & handle_event_selectively )
      end

      def application_kernel
        @app_kernel
      end

      def back_kernel

        # client #hook-in for nonstandard kernel exposure

        Home_.lib_.basic::Module.value_via_relative_path(
          self.class, DOT_DOT_
        ).application_kernel_
      end

      def branch_adapter_class_
        self.class::Branch_Adapter
      end

      def leaf_adapter_class_  # (related to above)
        self.class::Action_Adapter
      end

      def unbound_action_via_normalized_name i_a
        @app_kernel.unbound_action_via_normalized_name i_a
      end

      def lookup_sidesystem_module  # for auxiliaries, :+#hook-in

        ( s_a = self.class.name.split CONST_SEP_ ).pop
        Common_::Const_value_via_parts[ s_a ]
      end

      ## ~~ description & inflection

      def get_styled_description_string_array_via_name nm  # for #ouroboros
        [ "the #{ nm.as_slug } utility" ]  # placeholder
      end

      ## ~~ name & related

      def write_invocation_string_parts_into y  # [bs]
        y.concat @resources.invocation_string_array  # result
      end

      def app_name_string
        Common_::Name.via_module( @mod ).as_slug  # etc.
      end

      ## ~~ expag top-stopper

      def build_expression_agent_for_this_invocation invo
        Zerk_lib_[]::CLI::InterfaceExpressionAgent::THE_LEGACY_CLASS.
          via_expression_agent_injection invo
      end

      ## ~~ event receiving & sending

      def maybe_use_exit_status d  # #[#002.B]

        d or raise ::ArgumentError

        if instance_variable_defined? :@exitstatus
          x = @exitstatus
          if x < d
            yes = true
          end
        else
          yes = true
        end

        if yes
          @exitstatus = d
          NIL_
        end
      end

      def outbound_line_yielder_for__error__  # [css]
        outbound_line_yielder_for__info__
      end

      def outbound_line_yielder_for__info__  # [css]
        @___ioly ||= _build_output_line_yielder_around_IO @resources.serr
      end

      def outbound_line_yielder_for__payload__
        @___poly ||= _build_output_line_yielder_around_IO @resources.sout
      end

      def _build_output_line_yielder_around_IO io
        ::Enumerator::Yielder.new( & io.method( :puts ) )
      end

      public(
        :app_name_string,  # by our expag (covered by [f2])
        :application_kernel,
        :build_expression_agent_for_this_invocation,
        :branch_adapter_class_,
        :leaf_adapter_class_,
        :maybe_use_exit_status,
        :outbound_line_yielder_for__payload__,  # [gi]
        :_receive_invitation,
        :write_invocation_string_parts_into,
      )
    end  # top invocation

    # -- branch invocation (reduces unbounds to bounds)

    class Branch_Invocation__ < Invocation__
    private

      # -- branch - initialization

      def init_properties  # [*]
        @front_properties = Home_::CLI_Support.standard_branch_property_box
        NIL_
      end

      def properties
        @front_properties
      end

      # -- branch - reflection

      def didactic_argument_properties  # as branch, contrast with leaf
        _ = @categorized_properties.arg_a || EMPTY_A_
        [ * _, Ellipsis_hack___[] ]
      end

      Ellipsis_hack___ = Lazy_.call do

        # for now here is how we render the custom glyph `[..]` (was [#097])

        Home_::CLI_Support::Didactic_glyph[ :optional, DOT_DOT_, :_ellipsis_ ]
      end

      def _to_full_inferred_property_stream

        @front_properties.to_value_stream
      end

      # -- branch - invocation

      def receive_no_matching_via_token__ token

        _bc = _bound_call_for_unrecognized_via token
        call_bound_call _bc
      end

      def receive_multiple_matching_via_adapters_and_token__ a, token

        _bc = _bound_call_for_ambiguous_via a, token
        call_bound_call _bc
      end

      def call_bound_call exe
        exe.receiver.send exe.method_name, * exe.args
      end

      def _bound_call_from_parse_parameters  # branch; note super

        argv = @resources.argv

        if argv.length.zero?

          _bound_call_when_no_arguments

        elsif DASH_BYTE_ == argv.first.getbyte( 0 )

          super
        else
          _bound_call_via_action_looking_first_argument
        end
      end

      def _bound_action_via_normal_name i_a
        _bound_action_via_normal_name_symbol_stream(
          Common_::Scanner.via_array i_a )
      end

      def _bound_action_via_normal_name_symbol_stream sym_st

        ad_st = to_adapter_stream
        sym = sym_st.gets_one

        ad = ad_st.gets
        while ad
          if sym == ad.name.as_lowercase_with_underscores_symbol
            found = ad
            break
          end
          ad = ad_st.gets
        end

        if found
          found.prepare_for_employment_under self
          if sym_st.unparsed_exists
            found._bound_action_via_normal_name_symbol_stream sym_st
          else
            found
          end
        else
          raise ::KeyError, "not found: '#{ sym }'"
        end
      end

      def to_adapter_stream  # public because "when help" which is public

        o = _build_adapter_producer

        to_unordered_selection_stream.map_by do | unbound |

          o.adapter_for_unbound unbound
        end
      end

      def find_matching_action_adapters_against_tok_ tok

        o = _build_adapter_producer

        _unbound_a = __array_of_matching_unbounds_against_token tok

        _unbound_a.map do | unbound |

          o.adapter_for_unbound unbound
        end
      end

      def _build_adapter_producer

        Here_::Adapter_Producer___.new bound_, self
      end

      def leaf_adapter_class_
        @parent.leaf_adapter_class_
      end

      def branch_adapter_class_
        @parent.branch_adapter_class_
      end

      def __array_of_matching_unbounds_against_token tok

        p = fast_lookup_proc

        # the client can implement & expose this "fast lookup" to circumvent
        # needing to load (perhaps) all constituents to resolve a name.

        if p
          _nf = Common_::Name.via_slug tok
          # WAS: tok.gsub( DASH_, UNDERSCORE_ ).intern
          cls = p[ _nf ]
        end

        if cls
          [ cls ]
        else
          __array_of_matching_unbounds_against_token_slow tok
        end
      end

      def fast_lookup_proc
        bound_.fast_lookup
      end

      def __array_of_matching_unbounds_against_token_slow tok

        Home_.lib_.basic::Fuzzy.call_by do |o|

          o.string = tok

          o.stream = to_unordered_selection_stream

          o.string_via_item = -> unbound do  # (legacy name)
            unbound.name_function.as_slug
          end
        end
      end

      def to_unordered_selection_stream  # :+#public-API

        bound_.to_unordered_selection_stream
      end

      # --

      def __view_controller_class_for__help__option

        When_help__[]::For_Branch
      end

      # --

      def wrap_adapter_stream_with_ordering_buffer st

        Home_::Ordered_stream_via_participating_stream[ st ]
      end

      def _bound_call_for_unrecognized_via token

        When_[]::No_Matching_Action.new token, _expression, self
      end

      def bound_call_from_parse_arguments  # [cme]

        if @mutable_backbound_iambic.length.zero?
          if @resources.argv.length.zero?
            _bound_call_when_no_arguments
          else
            _bound_call_via_action_looking_first_argument
          end
        end
      end

      def _bound_call_when_no_arguments

        _prp = @front_properties.fetch :action
        When_[]::No_Arguments.new _prp, _expression
      end

      def _bound_call_via_action_looking_first_argument

        token = @resources.argv.shift
        @adapter_a = find_matching_action_adapters_against_tok_ token

        case 1 <=> @adapter_a.length

        when  0

          @adapter = remove_instance_variable( :@adapter_a ).fetch 0
          @adapter.bound_call_under self

        when  1
          _bound_call_for_unrecognized_via token

        when -1
          _bound_call_for_ambiguous_via @adapter_a, token

        end
      end

      def _bound_call_after_parse_parameters  # branch

        a = []
        st = Normal_stream___[ @mutable_backbound_iambic, @front_properties ]
        begin
          qkn = st.gets
          qkn or break

          sym = qkn.name_symbol
          _x = qkn.value

          _cls = ___view_controller_class_via_option_property_name_symbol sym
          o = _cls.new

          o.command_string = _x
          o.invocation_expression = _expression
          o.invocation_reflection = self
          a.push o

          redo
        end while nil

        Aggregate_Bound_Call__.new a
      end

      def ___view_controller_class_via_option_property_name_symbol sym

        m = _view_controller_class_method_for sym

        if respond_to? m
          send m
        else
          _const = Common_::Name.via_variegated_symbol( sym ).as_const
          When_[].const_get _const, false
        end
      end

      def _bound_call_for_ambiguous_via adapter_a, token

        When_[]::Multiple_Matching_Actions.
          new adapter_a, token, _expression
      end

      def resources  # bestowed to child from here, [tm]
        @resources
      end

      public(
        :didactic_argument_properties,
        :find_matching_action_adapters_against_tok_,
        :leaf_adapter_class_,
        :properties,
        :resources,
        :receive_multiple_matching_via_adapters_and_token__,
        :receive_no_matching_via_token__,
        :to_adapter_stream,
        :wrap_adapter_stream_with_ordering_buffer,
        :__view_controller_class_for__help__option,
      )

    end  # branch invocation

    # -- action adapter (combines invocation and adapter methods)

    Adapter_Methods__ = ::Module.new

    class Action_Adapter_ < Invocation__
    private

      include Adapter_Methods__

      # -- leaf - initialization

      def initialize unbound, boundish

        @_settable_by_environment_h = nil
        if unbound
          super
          @bound.accept_parent_node boundish
        end
      end

      # -- leaf - reflection

      def receive_show_help otr  # as leaf, contrast with branch; [tmx]

        prepare_for_employment_under otr

        o = When_help__[]::For_Action.new
        o.invocation_expression = _expression
        o.invocation_reflection = self
        o.execute
      end

      def custom_sections  # this is the frontier of burgeoning [#ze-061.2]:

        # for each category of item, and then for each item within each
        # category, use the [#] DSL, *while* reducing over the catogories
        # with no items.

        cp = @categorized_properties
        cat_st = ___to_relevant_category_stream
        category_renderers = __category_renderers

        once = -> do  # activate vendor interpreter IFF needed
          once = nil
          yield :allow_item_descriptions_to_have_N_lines, 2  # etc
        end

        begin
          begin
            cat = cat_st.gets
            cat or break
            prp_a = cp.for cat
            prp_a or redo
            break
          end while nil
          cat or break

          once && once[]

          # now you definitely have a section with nonzero items

          sym = cat.symbol
          yield :section, :name_symbol, sym
          p = category_renderers.fetch cat.symbol

          prp_a.each do |prp|
            yield :item, :moniker_proc, p[ prp ], :descriptor, prp
          end

          redo
        end while nil
        NIL_
      end

      def ___to_relevant_category_stream
        Common_::Stream.via_nonsparse_array Relevant_categories___[]
      end

      Relevant_categories___ = Lazy_.call do
        cats = Home_::CLI_Support::Categorized_Properties::CATEGORIES.dup
        cats[ cats.index { | cat | :option == cat.symbol } ] = nil
        cats.compact!
        cats
      end

      def __category_renderers

        _ = method :environment_variable_name_string_via_property_
        {
          argument: -> prp do
            -> _expag do
              Home_::CLI_Support::Syntax_Assembly.
                render_as_argument_uninflected_for_arity prp
            end
          end,
          environment_variable: -> prp do
            -> _expag do
              _[ prp ]
            end
          end,
        }
      end

      def didactic_argument_properties  # as leaf, contrast with branch. [cme]

        @categorized_properties.arg_a
      end

      def _to_full_inferred_property_stream

        _bx = Home_::CLI_Support.standard_action_property_box_

        _help = _bx.fetch :help

        Common_::Stream::CompoundStream.define do |o|
          o.add_stream to_property_stream
          o.add_item _help
        end
      end

      def to_property_stream
        if @front_properties
          @front_properties.to_value_stream
        else
          Common_::THE_EMPTY_STREAM
        end
      end

      # -- leaf - invocation

      def bound_call_from_parse_options  # [*]
        bc = super
        if bc
          bc
        elsif @seen[ :help ]
          bound_call_for_help_request
        end
      end

      def bound_call_for_help_request  # [ts]

        exp = _expression

        _m = _view_controller_class_method_for :help

        _cls = send _m  # ensure that it is explicit

        o = _cls.new
        o.invocation_expression = exp
        o.invocation_reflection = self

        a = []
        a.push o

        argv = @resources.argv

        if argv.length.nonzero?

          a.push When_[]::Unhandled_Arguments.new argv, exp
        end

        Aggregate_Bound_Call__.new a
      end

      def __view_controller_class_for__help__option

        When_help__[]::For_Action
      end

      def bound_call_from_parse_arguments  # (see other for extent)

        _n11n = Home_::CLI_Support::Arguments::Normalization.via_properties(
          @categorized_properties.arg_a || EMPTY_A_ )

        @arg_parse = _n11n.via_argv @resources.argv

        ev = @arg_parse.execute
        if ev
          send :"__bound_call_when__#{ ev.terminal_channel_symbol }__arguments", ev
        else
          @mutable_backbound_iambic.concat @arg_parse.release_result_iambic
          remove_instance_variable :@arg_parse
          NIL_
        end
      end

      def __bound_call_when__missing__arguments ev
        When_[]::Missing_Arguments.new ev.property, _expression
      end

      def __bound_call_when__extra__arguments ev
        When_[]::Extra_Arguments.new ev.x, _expression
      end

      def _bound_call_after_parse_parameters  # leaf

        if @categorized_properties.env_a
          __process_environment
        end

        ok = prepare_backstream_call @mutable_backbound_iambic

        if ok
          bound_call_via_bound_action_and_mutated_backbound_iambic
        else
          Common_::BoundCall.via_value ok  # failure is not an option
        end
      end

      def prepare_backstream_call x_a  # :+#public-API :+#hook-in
        ACHIEVED_
      end

      def remove_backstream_argument sym  # [gi]

        # until random access - go backwards from the end looking for it

        x_a = @mutable_backbound_iambic
        d = x_a.length - 2
        begin
          if sym == x_a.fetch( d )
            break
          end
          if 1 < d
            d -= 2
            redo
          end
          d = nil
          break
        end while nil
        d or raise ::NameError
        ___sketchily_remove_argument d, sym
      end

      def ___sketchily_remove_argument d, sym

        if d
          had = true
          x_a = @mutable_backbound_iambic
          x = x_a[ d + 1 ]
          x_a[ d, 2 ] = EMPTY_A_  # eew
        end

        Common_::QualifiedKnownness.via_value_and_had_and_association(
          x,
          had,
          @front_properties.fetch( sym ),
        )
      end

      def bound_call_via_bound_action_and_mutated_backbound_iambic

        # client may want to override this method if for example she is
        # [#043] backless and implements a custom front client.

        bc = @bound.bound_call_against_argument_scanner(

          Common_::Scanner.via_array @mutable_backbound_iambic )

        bc and bound_call_via_bound_call_from_back bc
      end

      def bound_call_via_bound_call_from_back bc  # :+#public-API :+#hook-in

        # experiment for [#060] the ability to customize rendering (beyond expag)

        bc
      end

      Autoloader_[ self ]

      public(
        :custom_sections,
        :didactic_argument_properties,
        :receive_show_help,
        :__view_controller_class_for__help__option,
      )
    end  # action adapter
    Action_Adapter = Action_Adapter_

    # -- branch adapter ( almost nothing special )

    class Branch_Adapter < Branch_Invocation__
    private

      include Adapter_Methods__

      def receive_show_help otr  # as branch, contrast with leaf, see [#]note-930

        prepare_for_employment_under otr
        o = When_help__[]::For_Branch.new
        o.invocation_expression = _expression
        o.invocation_reflection = self
        o.execute
      end

      public(
        :receive_show_help
      )
    end

    # -- adapter methods ( mainly delegates up/in )

    module Adapter_Methods__
    private

      def initialize unbound, boundish  # :+#public-API

        @bound = unbound.new boundish.kernel, & handle_event_selectively
      end

      # ~ implementation common to both branch & action (leaf) adapters:

      def bound_call_under otr  # :+#public-API
        prepare_for_employment_under otr
        _bound_call_from_parse_parameters
      end

      def prepare_for_employment_under otr
        @parent = otr
        @resources = otr.resources
        init_properties
        init_categorized_properties
        NIL_
      end

      # ~ delegate to (or derive trivially from) bound:

      ## ~~ description & inflection & name

      def name
        @bound.name
      end

      ## ~~ placement & visibility

      def name_value_for_order
        @bound.name.as_lowercase_with_underscores_symbol
      end

      def after_name_value_for_order
        @bound.after_name_symbol
      end

      def is_visible
        @bound.is_visible
      end

      # ~ delegate to parent:

      def write_invocation_string_parts_into y
        @parent.write_invocation_string_parts_into y
        y << name.as_slug
      end

      ## ~~ navigate the reactive model

      def _bound_action_via_normal_name i_a
        @parent._bound_action_via_normal_name i_a
      end

      def retrieve_unbound_action * i_a
        @parent.unbound_action_via_normalized_name i_a
      end

      def unbound_action_via_normalized_name i_a
        @parent.unbound_action_via_normalized_name i_a
      end

      ## ~~ events & related

      def send_invitation ev
        @parent._receive_invitation ev, self
      end

      def _receive_invitation ev, adapter
        @parent._receive_invitation ev, adapter
        NIL_
      end

      def expression_strategy_for_uncategorized_property prp
        @parent.expression_strategy_for_uncategorized_property prp
      end

      def outbound_line_yielder_for__payload__
        @parent.outbound_line_yielder_for__payload__
      end

      def maybe_use_exit_status d
        @parent.maybe_use_exit_status d
      end

      ## ~~ resources/services near kernel & application

      def app_name_string
        @parent.app_name_string
      end

      def application_kernel  # [tm]
        @parent.application_kernel
      end

      # ~ simple readers

      def bound_
        @bound
      end

      public(
        # UI
        :app_name_string,  # ibid
        :after_name_value_for_order,
        :is_visible,
        :name_value_for_order,
        :_receive_invitation,  # [gi]
        :write_invocation_string_parts_into,
        # invocation & lower
        :application_kernel,
        :bound_,
        :bound_call_under,
        :maybe_use_exit_status,
        :name,
      )
    end  # adapter methods

    # -- invocation ( the master base class - expresses events )

    class Invocation__
    private

      # the ordering rational for the sections is a mix between chronological
      # (in terms of invocation lifecycle) and high-level-to-low-level.

      # -- invocation - experimental property mutation API

      # ~ domain-specific property mutation: path

      def edit_path_properties sym, * sym_a

        absolutize_rel_paths = false
        become_not_required = false
        default_to_pwd = false
        do_this = false

        h = {
          absolutize_relative_path: -> do
            absolutize_rel_paths = true
            do_this = true
          end,
          default_to_PWD: -> do
            become_not_required = true
            default_to_pwd = true
            do_this = true
          end,
        }

        sym_a.each do | op_sym |
          h.fetch( op_sym ).call
        end

        if become_not_required

          # make this property not required in the eyes of the front.

          mutable_front_properties.replace_by sym do | prp |
            prp.dup.set_is_not_required.freeze
          end
        end

        if do_this

          mutable_back_properties.replace_by sym do | prp |

            otr = prp.dup

            if default_to_pwd
              otr.set_default_proc do
                present_working_directory
              end
            end

            if absolutize_rel_paths

              otr.append_ad_hoc_normalizer do | qkn, & x_p |
                __derelativize_path qkn, & x_p
              end
            end
            otr.freeze
          end
        end
        NIL_
      end

      def __derelativize_path qkn, & oes_p

        if qkn.is_known_known
          path = qkn.value
          if path
            if Home_.lib_.system.path_looks_relative path
              _path_ = _filesystem.expand_path path, present_working_directory
              kn = Common_::KnownKnown[ _path_ ]
            end
          end
        end

        kn || qkn.to_knownness
      end

      def present_working_directory
        _filesystem.pwd
      end

      def _filesystem
        # for now .. (but one day etc)
        Home_.lib_.system.filesystem
      end

      # -- invocation - init properties & categorized properties

      def init_properties  # :+[#042] #nascent-operation

        # at the time the action is invoked, mutate the properties we get
        # from the API to be customized for this modality for these actions.
        # it's CLI so there's no point in memoizing anything. load-time and
        # run-time are the same time.

        @mutable_back_properties = nil
        @mutable_front_properties = nil

        @back_properties = @bound.formal_properties  # nil ok

        if @back_properties
          mutate_properties  # if ever is needed, this might become unconditional
        end

        @front_properties ||= @back_properties

        NIL_
      end

      def mutate_properties

        sym_a = self.class::MUTATE_THESE_PROPERTIES
        if sym_a
          mutate_these_properties sym_a
        end
        NIL_
      end

      MUTATE_THESE_PROPERTIES = [ :stdin, :stdout ]

      def mutate_these_properties sym_a

        bp = @back_properties

        sym_a.each do | sym |
          if bp.has_key sym
            send :"mutate__#{ sym }__properties"
          end
        end
        NIL_
      end

      def mutate__stdout__properties  # an example

        substitute_value_for_argument :stdout do
          @resources.sout
        end
        NIL_
      end

      def substitute_knownness_for_argument sym, & arg_p

        mutable_front_properties.remove sym

        substitute_back_property_with_knownness_for_argument sym, & arg_p
      end

      def substitute_back_property_with_knownness_for_argument sym, & arg_p

        mutable_back_properties.replace_by sym do | prp |

          otr = prp.dup
          otr.append_ad_hoc_normalizer( & arg_p )
          otr
        end
      end

      def substitute_value_for_argument sym, & p

        mutable_front_properties.remove sym

        mutable_back_properties.replace_by sym do | prp |

          prp.new_with_default( & p ).freeze
        end
        NIL_
      end

      def build_property sym, * x_a  # [bs], [gi]

        ok = true
        prp = Home_::Modelesque::Entity::Property.new_by do

          @name = Common_::Name.via_variegated_symbol sym
          ok = process_iambic_fully x_a
        end
        ok or raise ::ArgumentError
        prp
      end

      def mutable_front_properties
        if ! @mutable_front_properties
          @mutable_front_properties = @back_properties.to_new_mutable_box_like_proxy
          @front_properties = @mutable_front_properties
        end
        @mutable_front_properties
      end

      def mutable_back_properties

        if @mutable_back_properties
          @mutable_back_properties
        else

          bx = @back_properties.to_mutable_box_like_proxy
          @mutable_back_properties = bx
          @bound.change_formal_properties bx  # might be same object
          bx
        end
      end

      def remove_property_from_front sym  # :+#by:ts
        mutable_front_properties.remove sym
        NIL_
      end

      def init_categorized_properties  # [ts], [cme]

        @categorized_properties = build_property_categorization.execute
        NIL_
      end

      def build_property_categorization

        o = Home_::CLI_Support::Categorized_Properties.begin

        o.property_stream = _to_full_inferred_property_stream

        o.settable_by_environment_h = _build_settable_by_environment_h

        o
      end

      # -- invocation - invocation

      def _bound_call_from_parse_parameters
        prepare_to_parse_parameters
        bc = bound_call_from_parse_options
        bc ||= bound_call_from_parse_arguments
        bc || _bound_call_after_parse_parameters
      end

      def prepare_to_parse_parameters  # [ts]

        @mutable_backbound_iambic = []  # ivar name is #public-API
        @seen = Common_::Box.new  # ivar name is #public-API
        NIL_
      end

      def bound_call_from_parse_options

        argv = @resources.argv
        op = _option_parser

        begin
          op.parse! argv
        rescue ::OptionParser::ParseError => e
        end

        if e
          When_[]::Parse_Error.new e.message, _expression
        end
      end

      # (the next few screens are arranged pursuant to [#]/figure-2)

      # -- invocation - expression

      def _expression
        @_expression ||= ___build_adapter_expression
      end

      def ___build_adapter_expression

        _expag = expression_agent

        _op = _option_parser

        _line_yielder = _info_line_yielder

        Here_::Adapter_Expression__.new _line_yielder, _expag, _op, self
      end

      def _info_line_yielder

        @___info_line_yielder ||= ::Enumerator::Yielder.new(
          & @resources.serr.method( :puts ) )
      end

      # -- invocation - as invocation reflection (assume expression)

      def description_proc_for_summary_under exp

        # #[#002.1] "an optimization for summary of child under parent"

        @bound.description_proc_for_summary_of_under self, exp
      end

      def description_proc
        bound_.description_proc
      end

      def write_any_auxiliary_syntax_strings_into_ y
        s = _help_syntax_string
        if s
          y << s
        end
        y
      end

      def _help_syntax_string  # (2x here)

        help = _to_full_inferred_property_stream.to_enum.detect do |prp|
          :help == prp.name_symbol
        end

        if help
          auxiliary_syntax_string_for_help_option_ help
        end
      end

      def auxiliary_syntax_string_for_help_option_ help  # (iso.client)

        _ = subprogram_name_string
        __ = @_expression.render_property_as_option_ help
        "#{ _ } #{ __ }"
      end

      def subprogram_name_string
        write_invocation_string_parts_into( [] ) * SPACE_
      end

      # -- invocation - o.p

      def _option_parser
        @___did_op ||= ___init_op
        @__op
      end

      def ___init_op
        op = begin_option_parser
        if op
          opt_a = @categorized_properties.opt_a
          if opt_a
            expression_agent  # (it's prettier if we access the ivar below)
            op = populated_option_parser_via opt_a, op
          end
        end
        @__op = op
        ACHIEVED_
      end

      def begin_option_parser  # :+#public-API
        option_parser_class.new
      end

      def option_parser_class
        Home_.lib_.stdlib_option_parser
      end

      def populated_option_parser_via opt_a, op  # [sg]

        Require_fields_lib_[]

        @__unique_letter_hash = Build_unique_letter_hash___[ opt_a ]

        opt_a.each do |prp|

          _args = ___optparse_args_for prp

          _p = optparse_behavior_for_property prp

          op.on( * _args, & _p )
        end

        remove_instance_variable :@__unique_letter_hash

        op
      end

      def ___optparse_args_for prp

        args = []

        letter = @__unique_letter_hash[ prp.name_symbol ]

        if letter
          args.push "-#{ letter }"
        end

        long = "--#{ prp.name.as_slug }"

        if Field_::Takes_argument[ prp ]

          moniker = Home_::CLI_Support::Option_argument_moniker_via_property[ prp ]

          if Field_::Argument_is_optional[ prp ]

            args.push "#{ long } [#{ moniker }]"  # no equals (covered)
          else
            args.push "#{ long } #{ moniker }"
          end
        else
          args.push long
        end

        if Field_::Has_description[ prp ]

          a = Field_::N_lines[ nil, @_expag, prp ]  # all lines

          if a
            args.concat a
          end
        end
        args
      end

      def optparse_behavior_for_property prp  # [ts]

        -> x do
          m = :"receive__#{ prp.name_symbol }__option"
          if respond_to? m
            send m, x, prp
          else
            ___receive_uncategorized_option x, prp
          end
          NIL_
        end
      end

      def ___receive_uncategorized_option x, prp

        Require_fields_lib_[]

        if Field_::Takes_argument[ prp ]

          if Field_::Takes_many_arguments[ prp ]

            mutate_backbound_iambic_ prp, [ x ]
          else

            mutate_backbound_iambic_ prp, x
          end
        elsif :zero_or_more == prp.parameter_arity

          mutate_backbound_iambic_( prp )._increment_seen_count  # :#here
        else

          mutate_backbound_iambic_ prp
        end
        NIL_
      end

      def mutate_backbound_iambic_ prp, * rest  # (iso.client)

        a = @mutable_backbound_iambic
        k = prp.name_symbol

        d = a.length
        a.push k, * rest

        amd = touch_argument_metadata k

        amd.add_seen_at_index d

        amd  # this result used in only one place currently (#here)
      end

      def increment_seen_count name_symbol  # [sn]

        touch_argument_metadata( name_symbol )._increment_seen_count
        NIL_
      end

      def touch_argument_metadata k  # [ts]

        @seen.touch k do
          Argument_Metadata___.new
        end
      end

      # -- invocation - expag

      def expression_agent  # [cme]
        @_expag ||= build_expression_agent_for_invocation
      end

      def build_expression_agent_for_invocation
        build_expression_agent_for_this_invocation self
      end

      def build_expression_agent_for_this_invocation invo
        @parent.build_expression_agent_for_this_invocation invo
      end

      # -- invocation - view controller ("when") support

      def _view_controller_class_method_for sym
        :"__view_controller_class_for__#{ sym }__option"
      end

      # -- invocation event handling ( implement #[#023] )

      def handle_event_selectively  # :+#public-API #hook-in

        # as it must it produces a [#ca-017] selective listener-style proc.
        # this default implementation accepts and routes every event to our
        # friendly general-purpose behavior dispatcher, but some hookers-in
        # will for example first check if a special method is defined which
        # corresponds to the channel name in some way and instead use that.

        @on_event_selectively ||= -> * i_a, & x_p do
          receive_uncategorized_emission i_a, & x_p
        end
      end

      def receive_uncategorized_emission i_a, & x_p

        bc = _emission_interpreter[ i_a, & x_p ]
        send bc.method_name, * bc.args, & bc.block
      end

      def _emission_interpreter
        Emission_interpreter___[]
      end

      Emission_interpreter___ = Lazy_.call do

        # NOTE this might become an overridable

        class Emission_Interpreter____ < Common_::Emission::Interpreter

          def __expression__ i_a, & x_p
            _ :"___express_expression", i_a, & x_p
          end

          def __data__ i_a, & x_p
            _ :__receive_data_emission, i_a, & x_p
          end

          def __conventional__ i_a, & x_p
            _ :receive_conventional_emission, i_a, & x_p
          end

          new.freeze
        end
      end

      def ___express_expression i_a, & y_p

        if :payload == i_a.first
          __express_emission_to_payload i_a, & y_p
        else
          _emit_contextualizable_non_payload_emission i_a, & y_p
        end
      end

      def receive_event_on_channel ev, i_a  # #public-API  [cm] [gv]

        if :payload == i_a.first
          _express_event_to_payload ev
        else
          _emit_contextualizable_non_payload_emission( i_a ) { ev }
        end
      end

      def receive_conventional_emission i_a, & ev_p  # #public-API [cm]

        if :payload == i_a.first
          _express_event_to_payload ev_p[]
        else
          _emit_contextualizable_non_payload_emission i_a, & ev_p
        end
      end

      def _express_event_to_payload ev

        _y = outbound_line_yielder_for__payload__
        ev.express_into_under _y, expression_agent
        UNRELIABLE_
      end

      def __express_emission_to_payload i_a, & y_p

        _y = outbound_line_yielder_for__payload__
        expression_agent.calculate _y, & y_p
        UNRELIABLE_
      end

      def _emit_contextualizable_non_payload_emission i_a, & x_p

        o = Home_.lib_.human::NLP::EN::Contextualization.begin

        o.given_emission i_a, & x_p

        o.idiom_for_neutrality = :Add_Nothing

        _expag = expression_agent
        _y = _info_line_yielder
        o.express_into_under _y, _expag

        __init_exitstatus_and_send_invite_via_c15n o

        UNRELIABLE_
      end

      def __receive_data_emission i_a, & x_p  # [cm]

        # this hooks out to methods the client itself must define.
        # NOTE below is #experimental - we may later omit the channel

        send :"receive__#{ i_a.fetch( 2 ) }__data", i_a, & x_p
      end

      # --

      def express_invite_to_general_help  # #todo - probably rename

        _expression.express_invite_to_general_help
      end

      def express & y_p  # [cme]

        expag = expression_agent

        y = _info_line_yielder

        if 1 == y_p.arity
          expag.calculate y, & y_p
        else
          y << expag.calculate( & y_p )
        end
        NIL_
      end

      def render_event_lines ev  # [ts]

        ev.express_into_under [], expression_agent
      end

      def send_non_payload_event_lines a  # [ts]

        a.each( & _info_line_yielder.method( :<< ) )
        NIL_
      end

      def __init_exitstatus_and_send_invite_via_c15n o

        wev = o.possibly_wrapped_event

        x = o.solve_for :trilean

        if wev
          if x.nil?
            maybe_use_exit_status SUCCESS_EXITSTATUS
          else
            ev = wev.to_event
            ___maybe_use_exit_status_via_OK_or_not_OK_event ev
            if false == x
              send_invitation ev
            end
          end
        elsif x
          maybe_use_exit_status SUCCESS_EXITSTATUS
        elsif x.nil?
          # ..
        else
          maybe_use_exit_status GENERIC_ERROR_EXITSTATUS
        end
        NIL_
      end

      def ___maybe_use_exit_status_via_OK_or_not_OK_event ev  # NOTE:
        # NOT for events where `ok` is nil (neutral events)
        d = _any_exit_status_for_event ev
        d or ev.ok && ( d = SUCCESS_EXITSTATUS )
        d ||= some_err_code_for_event ev
        maybe_use_exit_status d
        NIL_
      end

      def some_err_code_for_event ev
        _any_exit_status_for_event( ev ) || GENERIC_ERROR_EXITSTATUS
      end

      def _any_exit_status_for_event ev
        any_exit_status_for_channel_symbol ev.terminal_channel_symbol
      end

      def any_exit_status_for_channel_symbol sym
        Home_::API.exit_statii[ sym ]
      end

      def expression_strategy_for_property prp  # hook-out for expag

        sym = category_for prp
        if sym
          expression_strategy_for_category sym
        else
          expression_strategy_for_uncategorized_property prp
        end
      end

      def category_for prp
        @categorized_properties.__category_for prp
      end

      def expression_strategy_for_category sym
        :"render_property_as__#{ sym }__"
      end

      # -- experiment (see article) #[#101] (near [#060])

      def const_get_magically_ sym
        self.class.___const_get_magically sym
      end

      class << self

        def ___const_get_magically sym  # see line-by-line pseudocode

          kn = _cached sym
          if ! kn
            kn = _const_get_any_already_loaded sym
            kn ||= _const_get_any_using_filesystem_peek sym
            kn ||= ___const_get_support_node sym
            _cache kn, sym
          end
          kn.value
        end

        def ___const_get_support_node const

          _definitely_there Home_::CLI_Support, const
        end

        def _const_get_any_already_loaded const

          # if the *client* defined the const and it is already loaded

          if const_defined? const, false
            _definitely_there self, const
          end
        end

        def _const_get_any_using_filesystem_peek const

          if respond_to? :entry_tree

            _slug = Common_::Name.via_const_symbol( const ).as_slug

            ft = entry_tree

            if ft
              _sm = ft.asset_reference_via_entry_group_head _slug
              if _sm
                _definitely_there self, const
              end
            end
          end
        end

        def _definitely_there mod, const

          Common_::KnownKnown[ mod.const_get( const, false ) ]
        end

        def _cached sym
          ( @__tricky_cache ||= {} )[ sym ]
        end

        def _cache kn, sym
          @__tricky_cache[ sym ] = kn ; nil
        end
      end  # >>

      # --

      alias_method :option_parser, :_option_parser  # publicize only one

      public(
        :build_expression_agent_for_this_invocation,
        :category_for,  # [st]
        :const_get_magically_,  # performers
        :description_proc,  # expr
        :description_proc_for_summary_under,  # when help
        :expression_agent,  # 1x in file
        :expression_strategy_for_category,  # [st]
        :express_invite_to_general_help,
        :expression_strategy_for_property,
        :option_parser,
        :subprogram_name_string,
        :write_any_auxiliary_syntax_strings_into_,
      )

      alias_method :expression_, :_expression  # for iso.client, [pe]

    public

      def front_properties  # [bs], [st]
        @front_properties
      end
    end  # invocation

    # -- performers that interpret actual properties

    Normal_stream___ = -> mutable_backbound_iambic, props do

      Require_fields_lib_[]

      st = Common_::Scanner.via_array mutable_backbound_iambic

      Common_.stream do

        if st.unparsed_exists

          sym = st.gets_one
          prp = props.fetch sym

          if Field_::Takes_argument[ prp ]

            x = st.gets_one

            if Field_::Argument_is_optional[ prp ]

              if true == x  # #[#here.G]
                x = nil
              end
            end
          end

          Common_::QualifiedKnownKnown.via_value_and_association x, prp
        end
      end
    end

    class Argument_Metadata___

      def initialize
      end

      attr_reader :last_seen_index

      def add_seen_at_index d
        @last_seen_index = d
        NIL_
      end

      attr_reader :seen_count

      def _increment_seen_count
        if seen_count.nil?
          @seen_count = 1
        else
          @seen_count += 1
        end
      end
    end

    # -- performers that interpret formal properties

    Build_unique_letter_hash___ = -> opt_a do

      h = {}
      num_times_seen_h = ::Hash.new { | h_, k | h_[ k ] = 0 }

      opt_a.each do | prp |

        name_s = prp.name.as_variegated_string

        case num_times_seen_h[ name_s.getbyte( 0 ) ] += 1
        when 1
          h[ prp.name_symbol ] = name_s[ 0, 1 ]

        when 2
          h.delete prp.name_symbol
        end
      end
      h
    end

    # -- lower-level performers

    class Resources_HOT_NEW_TAKE___ < Common_::SimpleModel

      def initialize
        yield self
        @listener = method :__receive_emission
      end

      def expression_agent_by & p
        @expression_agent = :__expression_agent_via_proc
        @__expag_proc = p
      end

      def filesystem_by= p
        @filesystem = :__filesystem_via_proc
        @__filesystem_proc = p
      end

      def __stdin_stdout_stderr_ i, o, e
        @stdin = i ; @stdout = o ; @stderr = e ; nil
      end

      attr_writer(
        :argument_scanner,
        :filesystem,
        :receive_error_channel_by,
      )

      # --

      def __receive_emission *chan, & em_p

        expr = UI_::CLI_Express_via_Emission.define do |o|
          o.emission_proc_and_channel em_p, chan
          o.expression_agent_by = method :expression_agent
          o.stderr = @stderr
        end
        sct = expr.execute
        if sct && sct.was_error
          @receive_error_channel_by[ chan ]
        end
      end

      def expression_agent
        send @expression_agent
      end
      def __expression_agent_via_proc
        _p = remove_instance_variable :@__expag_proc
        @__expag = _p[]
        send( @expression_agent = :__expag_via_value )
      end
      def __expag_via_value
        @__expag
      end

      def filesystem
        send @filesystem
      end
      def __filesystem_via_proc
        @__FS = remove_instance_variable( :@__filesystem_proc )[]
        send( @filesystem = :__filesystem_via_value )
      end
      def __filesystem_via_value
        @__FS
      end

      attr_reader(
        :argument_scanner,
        :listener,
        :stderr,
        :stdin,
        :stdout,
      )
    end

    class Resources  # see [#110]

      attr_reader(
        :argv,
        :has_bridges,
        :_is_finished,
        :mod,
        :serr,
        :sin,
        :sout,
      )

      def initialize i, o, e, pn_s_a, mod

        @_bridges = nil
        @mod = mod
        @sin = i
        @serr = e
        @sout = o
        @_s_a = pn_s_a
      end

      def invocation_string_array
        @__ISR ||= __build_invocation_string_array
      end

      def __build_invocation_string_array

        s_a = remove_instance_variable :@_s_a

        if s_a
          if s_a.last.nil?
            s_a[ -1 ] = Common_::Name.via_module( @mod ).as_slug
          end
          s_a
        else
          [ ::File.basename( $PROGRAM_NAME ) ].freeze
        end
      end

      def _finish argv, a

        @argv = argv
        if a
          __receive_bridges a
        end
        @_is_finished = true
        NIL_
      end

      def __receive_bridges a

        h = @_bridges
        if ! h
          h = {}
          @has_bridges = true
          @_bridges = h
        end

        a.each_slice 2 do | k, x |
          h[ k ] = x
        end
        NIL_
      end

      def new argv
        otr = dup
        otr.reinit argv
        otr  # (used to freeze)
      end

      protected def reinit a
        @argv = a
        @_is_finished = true
        NIL_
      end

      # ~

      def knownness_for sym  # [gi]

        Common_::KnownKnown[ bridge_for( sym ) ]
      end

      def bridge_for sym

        ( @_bridges ||= {} ).fetch sym do
          @_bridges[ sym ] = send :"__default__#{ sym }__"
        end
      end

      def __default__environment__
        ::ENV
      end

      def __default__filesystem__

        Home_.lib_.system.filesystem  # directory? exist? mkdir mv open rmdir
      end

      def __default__system_conduit__

        Home_.lib_.open_3
      end
    end

    # -- bound proxies

    class Aggregate_Bound_Call__ < Home_::CLI_Support::As_Bound_Call

      def initialize a
        @a = a
      end

      def produce_result

        st = Common_::Stream.via_nonsparse_array @a

        begin
          bc = st.gets
          bc or break
          d = bc.receiver.send bc.method_name, * bc.args
          if d.nonzero?
            break
          end
          redo
        end while nil

        d  # exitstatus
      end
    end

    class Bound_Kernel___

      def initialize k, & oes_p
        @kernel = k
        @on_event_selectively = oes_p
      end

      # ~ delegation & related

      def description_proc
        @kernel.description_proc
      end

      def to_unordered_selection_stream

        @kernel.build_unordered_selection_stream(
          & @on_event_selectively )
      end

      def fast_lookup
        @kernel.fast_lookup
      end

      def name
        NIL_  # the top kernel *cannot* have a name, per :#here-2
      end

      attr_reader :kernel
    end

    # -- environment concern (experimental)

    class Branch_Invocation__
      def _build_settable_by_environment_h
        NIL_
      end
    end

    class Action_Adapter

      SETTABLE_BY_ENVIRONMENT = nil

      def _build_settable_by_environment_h

        a = self.class::SETTABLE_BY_ENVIRONMENT

        h = @_settable_by_environment_h

        if a

          h ||= {}
          a.each do | sym |
            h[ sym ] = true
          end
        end

        h
      end
    end

    class Action_Adapter  # re-open

      def __process_environment

        env = @resources.bridge_for :environment

        @categorized_properties.env_a.each do | prp |

          s = env[ environment_variable_name_string_via_property_ prp ]
          s or next
          cased_i = prp.name_symbol.downcase  # [#039] casing

          if @seen[ cased_i ]
            next
          end

          @mutable_backbound_iambic.push cased_i, s
        end
        NIL_
      end

      def environment_variable_name_string_via_property_ prp
        "#{ ___APPNAME }_#{ prp.name.as_lowercase_with_underscores_symbol.id2name.upcase }"
      end

      def ___APPNAME
        @___APPNAME ||= application_kernel.app_name_string.gsub( /[^[:alnum:]]+/, EMPTY_S_ ).upcase
      end
    end

    # ==

    Memoized_help_association_prototype___ = Lazy_.call do

      _defn = [
        :property,
        :help,
        :argument_is_optional,
        :description, -> { "this screen" },
      ]
      _gi = MTk_::EntityKillerParameter.grammatical_injection
      _scn = Scanner_[ _defn ]
      _gi.gets_one_item_via_scanner_fully _scn
    end

    # ==

    Desc_proc_via_module__ = -> mod do
      -> y do
        mod.describe_into_under y, self
      end
    end

    # ==

    o = Home_::CLI_Support

    When_help__ = -> do
      Zerk_lib_[]::NonInteractiveCLI::Help
    end

    # ==

    STOP_PARSING_ = nil

    # ==

    CLI_ = self
    DASH_BYTE_ = DASH_.getbyte 0
    GENERIC_ERROR_EXITSTATUS = o::GENERIC_ERROR_EXITSTATUS
    Here_ = self
    SUCCESS_EXITSTATUS = o::SUCCESS_EXITSTATUS
    When_ = -> { o::When }

    # ==
    # ==
  end
end
# #history-A.1: begin splicing matryoshka-killer in to legacy file
# #tombstone: re-entrancy
