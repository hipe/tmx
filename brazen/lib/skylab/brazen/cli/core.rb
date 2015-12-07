module Skylab::Brazen

  class CLI < ::Class.new ::Class.new  # see [#002]

    class << self

      def expose_executables_with_prefix s
        define_method :to_unordered_selection_stream,
          CLI_::Executables_Exposure___::Action_stream_method[ s ]
        NIL_
      end

      def expression_agent_instance
        Home_::CLI_Support::Expression_Agent.instance
      end

      def pretty_path x
        Home_::CLI_Support::Expression_Agent::Pretty_path[ x ]
      end

      def some_screen_width
        79  # :+#idea-kitestring for ncurses maybe
      end
    end  # >>

    Top_Invocation__ = self

    Branch_Invocation__ = Top_Invocation__.superclass

    Invocation__ = Branch_Invocation__.superclass

    class Top_Invocation__
    private

      def initialize i, o, e, pn_s_a, * x_a  # pn_s_a = program name string array

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

      def invoke argv

        rsx = @resources

        if rsx._is_finished
          # #experimental! subsequent invocation [sg]
          @resources = rsx.new argv
          @_expression = nil  # eew
        else
          rsx._finish argv, remove_instance_variable( :@_resource_components )
        end

        init_properties
        init_categorized_properties

        bc = _some_bound_call
        x = bc.receiver.send bc.method_name, * bc.args, & bc.block
        ___flush_any_invitations
        if x
          __result_as_top_via_trueish_backstream_result x
        else
          @exitstatus
        end
      end

      # ~ ( others at top, then the list from [#024] )

      ## ~~ help & invitations

      def ___flush_any_invitations

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

          CLI_::When_Result_::Looks_like_stream.new(
            x, @adapter, @adapter._expression_agent, @resources
          ).execute
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

      def _branch_class
        self.class::Branch_Adapter
      end

      def _leaf_class  # (related to above)
        self.class::Action_Adapter
      end

      def unbound_action_via_normalized_name i_a
        @app_kernel.unbound_action_via_normalized_name i_a
      end

      def lookup_sidesystem_module  # for auxiliaries, :+#hook-in

        ( s_a = self.class.name.split CONST_SEP_ ).pop
        Callback_::Const_value_via_parts[ s_a ]
      end

      ## ~~ description & inflection

      def get_styled_description_string_array_via_name nm  # for #ouroboros
        [ "the #{ nm.as_slug } utility" ]  # placeholder
      end

      ## ~~ name & related

      def _write_invocation_string_parts_into y
        y.concat @resources.invocation_string_array  # result
      end

      def app_name
        Callback_::Name.via_module( @mod ).as_slug  # etc.
      end

      ## ~~ expag top-stopper

      def _expression_agent_class

        self.class.___tricky_const_get :Expression_Agent
      end

      ## ~~ event receiving & sending

      def maybe_use_exit_status d  # #note-075

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

      def self.___tricky_const_get const  # experiment #[#101] (has line-by-line)

        cache = @___tricky_cache ||= {}
        cache.fetch const do
          x = if const_defined? const, false
            const_get const, false
          else

            _slug = Callback_::Name.via_const_symbol( const ).as_slug
            et = entry_tree

            if et.has_directory and et.has_entry_for_slug _slug
              const_get const, false  # hack trigger the autoload
            else
              Home_::CLI_Support.const_get const, false
            end
          end
          cache[ const ] = x
          x
        end
      end

      public(
        :app_name,  # by our expag (covered by [f2])
        :application_kernel,
        :_expression_agent_class,
        :invoke,
        :_leaf_class,
        :maybe_use_exit_status,
        :outbound_line_yielder_for__payload__,  # [gi]
        :_receive_invitation,
        :_write_invocation_string_parts_into,
      )
    end  # top invocation

    Lazy_ = Callback_::Lazy

    # -- branch invocation (reduces unbounds to bounds)

    class Branch_Invocation__ < Invocation__
    private

      # -- branch - initialization

      Actions = ::Module.new.freeze  # #note-165

      def init_properties  # [*]
        @front_properties = Standard_branch_property_box___[]
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

        # the syntax assembly does not yet have an API [designed] to support
        # custom glyphs like `[..]`. as long as this works .. (was [#097])

        Home_::CLI_Support::Modality_Specific_Property.new(
          :_ellipsis_hack_,
          :argument_argument_moniker, DOT_DOT_,
          :argument_arity, :one,
          :parameter_arity, :zero_or_one,
        )
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

      def _some_bound_call

        argv = @resources.argv

        if argv.length.zero?

          _bound_call_when_no_arguments

        elsif DASH_BYTE_ == argv.first.getbyte( 0 )

          __bound_call_via_option_looking_first_arg
        else
          _bound_call_via_action_looking_first_argument
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
          @adapter.bound_call_via_receive_frame self

        when  1
          _bound_call_for_unrecognized_via token

        when -1
          _bound_call_for_ambiguous_via @adapter_a, token

        end
      end

      def _bound_action_via_normal_name i_a
        _bound_action_via_normal_name_symbol_stream(
          Callback_::Polymorphic_Stream.via_array i_a )
      end

      def _bound_action_via_normal_name_symbol_stream sym_st

        ad_st = to_adapter_stream_
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
          found.accept_frame self
          if sym_st.unparsed_exists
            found._bound_action_via_normal_name_symbol_stream sym_st
          else
            found
          end
        else
          raise ::KeyError, "not found: '#{ sym }'"
        end
      end

      def to_adapter_stream_

        to_unordered_selection_stream.map_by do | unbound |

          adapter_via_unbound unbound

        end
      end

      def find_matching_action_adapters_against_tok_ tok

        _unbound_a = __array_of_matching_unbounds_against_token tok

        _unbound_a.map do | unbound |

          adapter_via_unbound unbound

        end
      end

      def __array_of_matching_unbounds_against_token tok

        p = fast_lookup_proc

        # the client can implement & expose this "fast lookup" to circumvent
        # needing to load (perhaps) all constituents to resolve a name.

        if p
          cls = p[ tok.gsub( DASH_, UNDERSCORE_ ).intern ]
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

        Home_.lib_.basic::Fuzzy.reduce_to_array_stream_against_string(
          to_unordered_selection_stream,
          tok,
          -> unbound do
            unbound.name_function.as_slug
          end )
      end

      def to_unordered_selection_stream  # :+#public-API

        bound_.to_unordered_selection_stream
      end

      def adapter_via_unbound unbound  # :+#public-API

        ada_cls = unbound.adapter_class_for :CLI

        if ! ada_cls
          ada_cls = if unbound.is_branch
            __branch_class_for_unbound_action unbound
          else
            __leaf_class_for_unbound_action unbound
          end
        end

        ada_cls.new unbound, bound_
      end

      # this is CLI. you need not cache these.

      def __view_controller_class_for__help__option

        When_[]::Help::For_Branch
      end

      def __branch_class_for_unbound_action unbound

        _any_specialized_adapter_in_self_for( unbound ) || _branch_class
      end

      def __leaf_class_for_unbound_action unbound

        _cls = __any_specialized_adapter_in_silo_for unbound

        _cls ||= _any_specialized_adapter_in_self_for unbound

        _cls || _leaf_class
      end

      # ~ begin modalities (per model)

      def __any_specialized_adapter_in_silo_for unbound  # leaf

        sm = unbound.silo_module

        if sm
          if sm.respond_to?( :entry_tree ) && sm.entry_tree.has_entry( MODA___ )

            # :+[#123] hacking a free peek into the filesystem is not as ugly
            # as a) needing to opt-in to boxxy everywhere or a) using stubs

            sm.const_get :Modalities, false
          end

          if sm.const_defined? :Modalities
            __any_branch_or_leaf_class_for_unbound_when_modalities unbound
          end
        end
      end

      def __any_branch_or_leaf_class_for_unbound_when_modalities unb

        sym = unb.name_function.as_const

        _source = unb.silo_module::Modalities::CLI::Actions

        if _source.const_defined? sym, false
          _source.const_get sym
        end
      end

      MODA___ = 'modalities'

      # ~ end

      def _any_specialized_adapter_in_self_for unbound  # branch or leaf

        # the "classical" way to override - all special actions in one file

        sym = unbound.name_function.as_const
        if self.class::Actions.const_defined? sym, false
          self.class::Actions.const_get sym
        end
      end

      def _leaf_class
        @parent._leaf_class
      end

      def _branch_class
        @parent._branch_class
      end

      def wrap_adapter_stream_with_ordering_buffer_ st
        Callback_::Stream.ordered st
      end

      def _bound_call_for_unrecognized_via token

        When_[]::No_Matching_Action.new token, _expression, self
      end

      def __bound_call_via_option_looking_first_arg

        prepare_to_parse_parameters
        bc = bound_call_from_parse_options
        bc or _bound_call_via_parsed_options
      end

      def _bound_call_via_parsed_options

        if @mutable_backbound_iambic.length.zero?
          if @resources.argv.length.zero?
            _bound_call_when_no_arguments
          else
            _bound_call_via_action_looking_first_argument
          end
        else
          __bound_call_via_successfully_parsed_options
        end
      end

      def __bound_call_via_successfully_parsed_options

        a = []
        st = Normal_stream___[ @mutable_backbound_iambic, @front_properties ]
        begin
          qkn = st.gets
          qkn or break

          sym = qkn.name_symbol
          _x = qkn.value_x

          cls = ___view_controller_class_via_option_property_name_symbol sym

          a.push cls.new( _x, _expression, self )
          redo
        end while nil

        Aggregate_Bound_Call__.new a
      end

      def ___view_controller_class_via_option_property_name_symbol sym

        m = _view_controller_class_method_for sym

        if respond_to? m
          send m
        else
          _const = Callback_::Name.via_variegated_symbol( sym ).as_const
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
        :_leaf_class,
        :properties,
        :resources,
        :receive_multiple_matching_via_adapters_and_token__,
        :receive_no_matching_via_token__,
        :to_adapter_stream_,
        :wrap_adapter_stream_with_ordering_buffer_,
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

      def receive_show_help_ otr  # as leaf, contrast with branch

        accept_frame otr

        _exp = _expression

        _when = When_[]::Help::For_Action.new nil, _exp, self

        _when.produce_result
      end

      def to_section_stream__  # not options. see [#]/figure-3

        cp = @categorized_properties
        cat_st = ___to_relevant_category_stream
        category_renderers = __category_renderers

        Callback_.stream do
          begin
            cat = cat_st.gets
            cat or break
            prp_a = cp.for cat
            prp_a or redo
            _nf = Callback_::Name.via_variegated_symbol cat.symbol
            p = category_renderers.fetch cat.symbol

            _st = Callback_::Stream.via_nonsparse_array prp_a do | prp |

              _name_x = p[ prp ]

              _desc_p = -> expag, n do
                if Field_::Has_description[ prp ]
                  Field_::N_lines[ n, expag, prp ]
                end
              end

              Callback_::Pair.via_value_and_name( _desc_p, _name_x )
            end

            x = Callback_::Pair.via_value_and_name( _st, _nf )
            break
          end while nil
          x
        end
      end

      def ___to_relevant_category_stream
        Callback_::Stream.via_nonsparse_array Relevant_categories___[]
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
                render_as_argument_uninflected_for_arity__ prp
            end
          end,
          environment_variable: -> prp do
            -> _expag do
              _[ prp ]
            end
          end,
        }
      end

      def didactic_argument_properties  # as leaf, contrast with branch

        @categorized_properties.arg_a
      end

      def _to_full_inferred_property_stream

        _bx = Home_::CLI_Support.standard_action_property_box_
        _help = _bx.fetch :help
        to_property_stream.push_by _help
      end

      def to_property_stream
        if @front_properties
          @front_properties.to_value_stream
        else
          Callback_::Stream.the_empty_stream
        end
      end

      # -- leaf - invocation

      def _some_bound_call
        prepare_to_parse_parameters
        bc = bound_call_from_parse_options
        bc or _bound_call_via_parsed_options
      end

      def _bound_call_via_parsed_options

        if @seen[ :help ]
          bound_call_for_help_request
        else
          bound_call_via_ARGV_
        end
      end

      def bound_call_for_help_request  # [ts]

        exp = _expression

        _m = _view_controller_class_method_for :help

        _cls = send _m  # ensure that it is explicit

        _when = _cls.new nil, exp, self

        a = []
        a.push _when

        argv = @resources.argv

        if argv.length.nonzero?

          a.push When_[]::Unhandled_Arguments.new argv, exp
        end

        Aggregate_Bound_Call__.new a
      end

      def __view_controller_class_for__help__option

        When_[]::Help::For_Action
      end

      def bound_call_via_ARGV_

        _n11n = Home_::CLI_Support::Arguments::Normalization.via_properties(
          @categorized_properties.arg_a || EMPTY_A_ )

        @arg_parse = _n11n.new_via_argv @resources.argv

        ev = @arg_parse.execute
        if ev
          __bound_call_when_ARGV_parsing_error_event ev
        else
          __bound_call_via_parsed_ARGV
        end
      end

      def __bound_call_when_ARGV_parsing_error_event ev
        send :"__bound_call_when__#{ ev.terminal_channel_i }__arguments", ev
      end

      def __bound_call_when__missing__arguments ev
        When_[]::Missing_Arguments.new ev.property, _expression
      end

      def __bound_call_when__extra__arguments ev
        When_[]::Extra_Arguments.new ev.x, _expression
      end

      def __bound_call_via_parsed_ARGV

        @mutable_backbound_iambic.concat @arg_parse.release_result_iambic

        if @categorized_properties.env_a
          bc = __process_environment
        end

        if bc
          bc
        else
          __bound_call_via_mutable_backbound_iambic
        end
      end

      def __bound_call_via_mutable_backbound_iambic

        ok = prepare_backstream_call @mutable_backbound_iambic

        if ok
          bound_call_via_bound_action_and_mutated_backbound_iambic
        else
          Callback_::Bound_Call.via_value ok  # failure is not an option
        end
      end

      def prepare_backstream_call x_a  # :+#public-API :+#hook-in

        ACHIEVED_
      end

      def remove_backstream_option_argument sym

        seen = @seen[ sym ]
        if seen
          _d = seen.last_seen_index
        end
        _sketchily_remove_argument _d, sym
      end

      def remove_backstream_argument sym

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
        _sketchily_remove_argument d, sym
      end

      def _sketchily_remove_argument d, sym

        if d
          had = true
          x_a = @mutable_backbound_iambic
          x = x_a[ d + 1 ]
          x_a[ d, 2 ] = EMPTY_A_  # eew
        end

        Callback_::Qualified_Knownness.via_value_and_had_and_association(
          x,
          had,
          @front_properties.fetch( sym ),
        )
      end

      def bound_call_via_bound_action_and_mutated_backbound_iambic

        # client may want to override this method if for example she is
        # [#043] backless and implements a custom front client.

        bc = @bound.bound_call_against_polymorphic_stream(

          Callback_::Polymorphic_Stream.via_array @mutable_backbound_iambic )

        bc and bound_call_via_bound_call_from_back bc
      end

      def bound_call_via_bound_call_from_back bc  # :+#public-API :+#hook-in

        # experiment for [#060] the ability to customize rendering (beyond expag)

        bc
      end

      Autoloader_[ self ]

      public(
        :didactic_argument_properties,
        :receive_show_help_,
        :to_section_stream__,
        :__view_controller_class_for__help__option,
      )
    end  # action adapter
    Action_Adapter = Action_Adapter_

    # -- branch adapter ( almost nothing special )

    class Branch_Adapter < Branch_Invocation__
    private

      include Adapter_Methods__

      def receive_show_help_ otr  # as branch, contrast with leaf, see [#]note-930

        accept_frame otr

        When_[]::Help::For_Branch.new(
          nil, _expression, self
        ).produce_result
      end

      public(
        :receive_show_help_
      )
    end

    # -- adapter methods ( mainly delegates up/in )

    module Adapter_Methods__
    private

      def initialize unbound, boundish  # :+#public-API

        @bound = unbound.new boundish.kernel, & handle_event_selectively
      end

      # ~ implementation common to both branch & action (leaf) adapters:

      def bound_call_via_receive_frame otr  # :+#public-API
        accept_frame otr
        _some_bound_call
      end

      def accept_frame otr
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

      def _write_invocation_string_parts_into y
        @parent._write_invocation_string_parts_into y
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

      def _expression_strategy_for_uncategorized_property prp
        @parent._expression_strategy_for_uncategorized_property prp
      end

      def _expression_agent_class
        @parent._expression_agent_class
      end

      def outbound_line_yielder_for__payload__
        @parent.outbound_line_yielder_for__payload__
      end

      def maybe_use_exit_status d
        @parent.maybe_use_exit_status d
      end

      ## ~~ resources/services near kernel & application

      def app_name
        @parent.app_name
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
        :app_name,  # ibid
        :after_name_value_for_order,
        :_expression_agent_class,
        :is_visible,
        :name_value_for_order,
        :_receive_invitation,  # [gi]
        :_write_invocation_string_parts_into,
        # invocation & lower
        :application_kernel,
        :bound_,
        :bound_call_via_receive_frame,
        :maybe_use_exit_status,
        :name,
      )
    end  # adapter methods

    # -- invocation ( the master base class - expresses events )

    class Invocation__
    private

      MUTATE_THESE_PROPERTIES = [ :stdin, :stdout ]

      # the ordering rational for the sections is a mix between chronological
      # (in terms of invocation lifecycle) and high-level-to-low-level.

      # -- invocation - initialization

      def init_categorized_properties  # [ts]

        o = Home_::CLI_Support::Categorized_Properties.begin

        o.property_stream = _to_full_inferred_property_stream

        o.settable_by_environment_h = __build_settable_by_environment_h_

        cp = o.execute
        @categorized_properties = cp

        # (visible by child classes, but not outside of sidesys. however
        #  because the surrounding method is public API so is this name.)

        NIL_
      end

      # -- invocation - invocation

      def prepare_to_parse_parameters  # [ts], branch & leaf

        @mutable_backbound_iambic = []  # ivar name is #public-API
        @seen = Callback_::Box.new  # ivar name is #public-API
        NIL_
      end

      def bound_call_from_parse_options  # [*]

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

        _expag = _expression_agent

        _op = _option_parser

        _puts = @resources.serr.method :puts
        _line_yielder = ::Enumerator::Yielder.new( & _puts )

        CLI_::Adapter_Expression__.new _line_yielder, _expag, _op, self
      end

      # -- invocation - as invocation reflection (assume expression)

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

        help = _to_full_inferred_property_stream.each.detect do | prp |
          :help == prp.name_symbol
        end

        if help
          auxiliary_syntax_string_for_help_option_ help
        end
      end

      def auxiliary_syntax_string_for_help_option_ help  # (iso.client)

        _ = subprogram_name_string_
        __ = @_expression.render_property_as_option_ help
        "#{ _ } #{ __ }"
      end

      def subprogram_name_string_
        _write_invocation_string_parts_into( [] ) * SPACE_
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
            _expression_agent  # (it's prettier if we access the ivar below)
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

      def _expression_agent
        @_expag ||= _expression_agent_class.new self
      end

      # -- invocation - view controller ("when") support

      def _view_controller_class_method_for sym
        :"__view_controller_class_for__#{ sym }__option"
      end

      # -- invocation event handling ( implement #[#023] )

      def handle_event_selectively  # :+#public-API #hook-in

        # as it must it produces a [#cb-017] selective listener-style proc.
        # this default implementation accepts and routes every event to our
        # friendly general-purpose behavior dispatcher, but some hookers-in
        # will for example first check if a special method is defined which
        # corresponds to the channel name in some way and instead use that.

        @on_event_selectively ||= -> * i_a, & x_p do
          receive_uncategorized_emission i_a, & x_p
        end
      end

      def receive_uncategorized_emission i_a, & x_p

        if i_a
          sym = i_a[ 1 ]
        end

        case sym
        when :expression

          send :"receive__#{ i_a[ 0 ] }__expression", * i_a[ 2 .. -1 ], & x_p

        when :data

          __receive_data_emission i_a, & x_p

        else

          receive_conventional_emission i_a, & x_p
        end
      end

      def __receive_data_emission i_a, & x_p  # publicize whenever

        # NOTE below signature is :+#experimental. we may later omit the channel

        send :"receive__#{ i_a.fetch( 2 ) }__data", i_a, & x_p
      end

      def receive__error__expression sym, & msg_p

        receive_negative_event _event_via_expression( false, sym, & msg_p )
      end

      def receive__info__expression sym, & msg_p

        receive_neutral_event _event_via_expression( nil, sym, & msg_p )
      end

      def receive__payload__expression sym, & msg_p

        receive_payload_event _event_via_expression( true, sym, & msg_p )
      end

      def _event_via_expression ok, sym, & msg_p

        Callback_::Event.inline_with sym, :ok, ok do | y, _ |
          instance_exec y, & msg_p
        end
      end

      def receive_conventional_emission i_a, & ev_p  # :+#public-API

        if ev_p
          receive_event_on_channel ev_p[], i_a
        else
          self._COVER_ME_emission_does_not_comply_to_this_modality
        end
      end

      def receive_event_on_channel ev, i_a  # :+#public-API

        ev_ = ev.to_event

        has_OK_tag = if ev_.has_member :ok
          ok_x = ev_.ok
          true
        end

        if has_OK_tag && ! ok_x.nil?
          if ok_x
            if ev_.has_member :is_completion and ev_.is_completion
              receive_completion_event ev
            elsif :payload == i_a.first  # or ! ev.verb_lexeme
              receive_payload_event ev
            else
              receive_positive_event ev
            end
          else
            receive_negative_event ev
          end
        else
          receive_neutral_event ev
        end
      end

      def receive_positive_event ev
        ev_ = ev.to_event
        a = render_event_lines ev
        s = inflect_line_for_positivity_via_event a.first, ev
        s and a[ 0 ] = s
        send_non_payload_event_lines_with_redundancy_filter a
        maybe_use_exit_status_via_OK_or_not_OK_event ev_
        NIL_
      end

      def receive_negative_event ev
        a = render_event_lines ev
        s = maybe_inflect_line_for_negativity_via_event a.first, ev
        s and a[ 0 ] = s
        send_non_payload_event_lines_with_redundancy_filter a
        send_invitation ev
        maybe_use_exit_status some_err_code_for_event ev
        NIL_
      end

      def receive_success_event ev
        receive_completion_event ev  # while it works
      end

      def receive_completion_event ev
        a = render_event_lines ev
        s = maybe_inflect_line_for_completion_via_event a.first, ev
        s and a[ 0 ] = s
        send_non_payload_event_lines a
        maybe_use_exit_status SUCCESS_EXITSTATUS
        NIL_
      end

      def receive_neutral_event ev
        a = render_event_lines ev
        send_non_payload_event_lines a
        maybe_use_exit_status SUCCESS_EXITSTATUS
        NIL_
      end

      def express_invite_to_general_help

        _expression.express_invite_to_general_help
      end

      def receive_payload_event ev
        send_payload_event_lines render_event_lines ev
        maybe_use_exit_status_via_OK_or_not_OK_event ev.to_event
      end

      def receive_info_event ev
        _a = render_event_lines ev
        send_non_payload_event_lines _a
        NIL_
      end

      # ~ #GEC

      def maybe_inflect_line_for_positivity_via_event s, ev
        if ev.verb_lexeme
          inflect_line_for_positivity_via_event s, ev
        else
          s
        end
      end

      def inflect_line_for_positivity_via_event s, ev
        if ev.respond_to? :inflected_noun
          __ilfp s, ev
        else
          s
        end
      end

      def __ilfp s, ev

        open, inside, close = unparenthesize s

        _mutate_by_maybe_downcasing_first inside

        n_s = ev.inflected_noun
        v_s = ev.verb_lexeme.progressive
        gerund_phrase = "#{ [ v_s, n_s ].compact * SPACE_ }"

        _inside_ = if LOOKS_LIKE_ONE_WORD_RX__ =~ inside
          "#{ inside } #{ gerund_phrase }"
        else
          "while #{ gerund_phrase }, #{ inside }"
        end

        "#{ open }#{ _inside_ }#{ close }"
      end

      def maybe_inflect_line_for_negativity_via_event s, ev
        open, inside, close = unparenthesize s
        _mutate_by_maybe_downcasing_first inside
        if ev.respond_to? :inflected_verb
          v_s = ev.inflected_verb
          lex = ev.noun_lexeme and n_s = lex.lemma
          prefix = "couldn't #{ [ v_s, n_s ].compact * SPACE_ } because "
        end
        "#{ open }#{ prefix }#{ inside }#{ close }"
      end

      def maybe_inflect_line_for_completion_via_event s, ev
        if ev.respond_to? :inflected_noun
          __milfc s, ev
        else
          s
        end
      end

      def __milfc s, ev

        open, inside, close = unparenthesize s
        _mutate_by_maybe_downcasing_first inside

        if LOOKS_LIKE_ONE_WORD_RX__ =~ inside

          maybe_inflect_line_for_positivity_via_event s, ev

        else

          n_s = ev.inflected_noun
          v_s = ev.verb_lexeme.preterite

          prefix = if n_s
            "#{ v_s } #{ n_s }: "
          else
            v_s
          end

          "#{ open }#{ prefix }#{ inside }#{ close }"
        end
      end

      LOOKS_LIKE_ONE_WORD_RX__ = /\A[a-z]+\z/

      def unparenthesize s
        LIB_.basic::String.unparenthesize_message_string s
      end

      define_method :_mutate_by_maybe_downcasing_first, -> do
        rx = nil
        -> s do
          if s
            rx ||= /\A[A-Z](?![A-Z])/
            s.sub! rx do | s_ |
              s_.downcase!
            end
            NIL_
          end
        end
      end.call

      def render_event_lines ev
        ev.express_into_under y=[], _expression_agent
        y
      end

      def send_non_payload_event_lines_with_redundancy_filter a
        if 1 == a.length
          s = redundancy_filter[ a.first ]
          send_non_payload_event_lines [ s ]
        else
          send_non_payload_event_lines a
        end
      end

      def redundancy_filter
        @redundancy_filter ||= CLI_::Adapter_Expression__::Redundancy_Filter.new
      end

      def send_payload_event_lines a
        a.each( & outbound_line_yielder_for__payload__.method( :<< ) )
        NIL_
      end

      def send_non_payload_event_lines a

        a.each( & _expression.line_yielder.method( :<< ) )
        NIL_
      end

      def maybe_use_exit_status_via_OK_or_not_OK_event ev
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
        any_exit_status_for_channel_symbol ev.terminal_channel_i
      end

      def any_exit_status_for_channel_symbol sym
        Home_::API.exit_statii[ sym ]
      end

      def expression_strategy_for_property prp  # hook-out for expag

        sym = category_for prp
        if sym
          expression_strategy_for_category sym
        else
          _expression_strategy_for_uncategorized_property prp
        end
      end

      def category_for prp
        @categorized_properties.__category_for prp
      end

      def expression_strategy_for_category sym
        :"render_property_as__#{ sym }__"
      end

      alias_method :option_parser__, :_option_parser  # publicize only one

      public(
        :category_for,  # [st]
        :description_proc,  # expr
        :_expression_agent,  # 1x in file
        :expression_strategy_for_category,  # [st]
        :express_invite_to_general_help,
        :expression_strategy_for_property,
        :option_parser__,
        :subprogram_name_string_,
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

      st = Callback_::Polymorphic_Stream.via_array mutable_backbound_iambic

      Callback_.stream do

        if st.unparsed_exists

          sym = st.gets_one
          prp = props.fetch sym

          if Field_::Takes_argument[ prp ]

            x = st.gets_one

            if Field_::Argument_is_optional[ prp ]

              if true == x  # :Spot-1 ([#])
                x = nil
              end
            end
          end

          Callback_::Qualified_Knownness.via_value_and_association x, prp
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

    # -- performers that model formal properties

    Standard_branch_property_box___ = Callback_::Lazy.call do

      _Property = Home_::CLI_Support::Modality_Specific_Property

      bx = Box_.new

      bx.add :action, _Property.new( :action, :is_required, true )

      bx.add :help, _Property.new( :help,

        :description_proc, -> y do
          y << 'this screen (or help for action)'
        end,

        :option_argument_moniker, 'cmd',
        :parameter_arity, :zero_or_one,
        :argument_arity, :zero_or_one,  # LOOK Spot-1
      )

      bx.freeze
    end

    # -- lower-level performers

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
            s_a[ -1 ] = Callback_::Name.via_module( @mod ).as_slug
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

        Callback_::Known_Known[ bridge_for( sym ) ]
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

        st = Callback_::Stream.via_nonsparse_array @a

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

    # -- environment concern ( #todo - gut this )

    class Branch_Invocation__
      def __build_settable_by_environment_h_
        NIL_
      end
    end

    class Action_Adapter

      SETTABLE_BY_ENVIRONMENT = nil

      def __build_settable_by_environment_h_

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

    class Top_Invocation__

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

        ( @_resource_components ||= [] ).push sym, x
        NIL_
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
        "#{ __APPNAME }_#{ prp.name.as_lowercase_with_underscores_symbol.id2name.upcase }"
      end

      def __APPNAME
        @__APPNAME ||= application_kernel.app_name.gsub( /[^[:alnum:]]+/, EMPTY_S_ ).upcase
      end
    end

    # --

    # ~ demonstration of modality-specific formal property mutation

    class Client_for_Brazen_as_Application < self

      # (normally you would call your subclass `CLI`, but we can't here)

      def back_kernel
        Home_.application_kernel_
      end

      class Action_Adapter < Action_Adapter  # #pedgogy-1875

        MUTATE_THESE_PROPERTIES = [
          :config_filename,
          :config_path,
          :max_num_dirs,
          :path,
          :workspace_path ]

        def mutate__config_filename__properties

          # exclude this formal property from the front. leave back as-is.

          mutable_front_properties.remove :config_filename
          NIL_
        end

        def mutate__max_num_dirs__properties  # ALSO handwritten below!

          # in the front, tag this property as mutable by the environment

          @_settable_by_environment_h ||= {}
          @_settable_by_environment_h[ :max_num_dirs ] = true

          mutable_back_properties.replace_by :max_num_dirs do | prp |

            # tricky - the back is written around having a default so it
            # expects the element to be set always in its box hence we change
            # the default to be nil rather than removing the default
            # entirely (covered)

            prp.new_with_default do
              NIL_
            end
          end

          NIL_
        end

        def mutate__path__properties

          edit_path_properties :path, :default_to_PWD
        end

        def mutate__workspace_path__properties

          # exclude this formal property from the front. default the back to CWD

          substitute_value_for_argument :workspace_path do
            present_working_directory
          end
          NIL_
        end
      end

      Actions = ::Module.new  # #pedagogy-1975

      class Actions::Init < Action_Adapter

        def mutate__path__properties

          # override parent to do nothing. we want the `path` property to
          # stay required. we do not do any defaulting for this field for
          # this action. the user must indicate the path explicitly here.
        end
      end
    end

    ## ~~ here is our support in the library for the above

    class Action_Adapter  # re-re-open

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

      def mutate_these_properties sym_a

        bp = @back_properties

        sym_a.each do | sym |
          if bp.has_name sym
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

      def build_property sym, * x_a  # convenience

        ok = true
        prp = Home_::Modelesque::Entity::Property.new do

          @name = Callback_::Name.via_variegated_symbol sym
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

      # ~ experimenal domain-specific property mutation API & support

      ## ~~ near filesystem

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
          path = qkn.value_x
          if path
            if FILE_SEPARATOR_BYTE != path.getbyte( 0 )  # ick/meh

              _path_ = _filesystem.expand_path path, present_working_directory
              kn = Callback_::Known_Known[ _path_ ]
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

      # ~ property mutation API & support (#experimental)

      def remove_property_from_front sym  # :+#by:ts
        mutable_front_properties.remove sym
        NIL_
      end
    end

    o = Home_::CLI_Support

    FILE_SEPARATOR_BYTE = o::FILE_SEPARATOR_BYTE
    CLI_ = self
    DASH_BYTE_ = DASH_.getbyte 0
    GENERIC_ERROR_EXITSTATUS = o::GENERIC_ERROR_EXITSTATUS
    NOTHING_ = nil
    SUCCESS_EXITSTATUS = o::SUCCESS_EXITSTATUS
    When_ = -> { o::When }

  end
end
