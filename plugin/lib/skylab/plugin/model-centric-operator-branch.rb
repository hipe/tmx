module Skylab::Plugin

  module ModelCentricOperatorBranch

    # introduction and tutorial/case-study at [#011]

    # primarily this file's responsibility is to know how to load endpoints.
    # this can involve the loading of not just the endpoints themselves, but
    # their (any) "pure branch node" (a.k.a "splay [module]"), and possibly
    # the parent module of these modules too (i.e a business model node).
    #
    # (for an in-depth discussion of this architectural convention see
    # [#br-013] (which is at present half out-of-date but still spiritually
    # relevant).)
    #
    # there are 3 ways (currently) endpoints can be "positioned" "physically":
    #
    #   1) "conventionally" which is where each action gets its own file
    #   2) all actions (and only actions) in one file
    #   3) all actions ["already"] defined in their business parent node file.
    #
    # currently it's all or nothing, i.e. for any given splay you can't
    # mix-and-match the above techniques (although using a technique with
    # a lower number might just magically work "out of the box" on techniques
    # of a higher number, we're not sure.)
    #
    # (more about each above sub-convention at its corresponding section below.)

    # the code file is in three sections (easy jump):
    #   - section 1 of 3 - define-time
    #   - section 2 of 3 - operator branch via [3 means]
    #   - section 3 of 3 - support (shared)

    class << self

      def define & p
        Require_these___[]
        Define___.call_by( & p )
      end
    end  # >>

    # == section 1 of 3 - define-time

    class Define___ < Common_::MagneticBySimpleModel

      def initialize
        @_a = []
        yield self
      end

      def add_model_modules_glob glob, tail
        @_a.push ModelModulesGlob___.new glob, tail ; nil
      end

      def add_actions_modules_glob glob
        @_a.push ActionsModulesGlob___.new glob ; nil
      end

      def add_actions_module_path_tail tail
        @_a.push ActionsModulePathTail___.new tail ; nil
      end

      attr_writer(
        :bound_call_when_operation_with_definition_by,
        :filesystem,
        :models_branch_module,
      )

      def execute

        fs = remove_instance_variable :@filesystem

        _ir = LocalInvocationResources___.new(
          remove_instance_variable( :@bound_call_when_operation_with_definition_by ),
          fs,
        )

        gr = GlobResources___.new(
          remove_instance_variable( :@models_branch_module ),
          fs,
        )

        paths = []
        remove_instance_variable( :@_a ).each do |obj|
          obj.write_into_using paths, gr
        end
        _path_scanner = Scanner_[ paths ]

        OperatorBranch_via_ActionsPaths___.new _path_scanner, gr, _ir
      end
    end

    class ModelModulesGlob___

      # #experimental - for [tm]: using only a glob of models (not actions),
      # spoof it as if every model has an "actions" node, so that UMM..

      def initialize s, s_
        @glob = s ; @tail = s_
      end

      def write_into_using y, o
        glob = ::File.join o.path_head, @glob
        a = o.filesystem.glob glob
        a.length.zero? and raise This_one_exception__[ glob ]
        a.each do |path|
          d = ::File.extname( path ).length
          if d.nonzero?
            path[ -d .. -1 ] = EMPTY_S_  # (information is lost here)
          end
          y << ::File.join( path, @tail )
        end
        NIL
      end
    end

    class ActionsModulesGlob___

      # implement this kind of path glob specification.

      def initialize s
        @glob = s
      end

      def write_into_using y, o
        glob = ::File.join o.path_head, @glob
        a = o.filesystem.glob glob
        a.length.zero? and raise This_one_exception__[ glob ]
        y.concat a ; nil
      end
    end

    class ActionsModulePathTail___

      # implement this kind of path glob specification (not actually a glob)

      def initialize s
        @path_tail = s
      end

      def write_into_using y, o
        y << ::File.join( o.path_head, @path_tail )
      end
    end

    This_one_exception__ = -> glob do
      # this is intended as a sanity check for developers.
      # this should not be made into an emission.
      ::RuntimeError.new "this is probably not what you want. zero paths - #{ glob }"
    end

    # == section 2 of 3 - operator branch via [3 means]

    # ~ 1. via actionS paths

    class OperatorBranch_via_ActionsPaths___

      # very close to [#pl-012] "operator branch via directories one deeper".
      # also stay close to our counterpart #here1.

      def initialize scn, gr, lirx
        @glob_resources = gr
        @local_invocation_resources = lirx

        @__localize = Home_.lib_.basic::Pathname::Localizer[ gr.path_head ]

        @_implementor = CachingOperatorBranch__.new scn do |path|
          __build_loadable_reference_via_path path  # hi.
        end
      end

      def dereference ref
        k = ref.intern
        _x = lookup_softly k
        _x or raise ::NameError, k
        _x
      end

      def lookup_softly k
        @_implementor._lookup_softly k
      end

      def to_loadable_reference_stream
        @_implementor._to_loadable_reference_stream
      end

      def __build_loadable_reference_via_path path

        _tail = @__localize[ path ]

        # _tail  # =>  "ping/actions", "tag/actions.rb"

        s_a = _tail.split ::File::SEPARATOR

        case s_a.length
        when 2
          entry = s_a.pop
          d = ::File.extname( entry ).length
          _stem = if d.zero?
            entry  # "actions"
          else
            entry[ 0 ... -d ]  # "actions.rb" => "actions"  [#here.2]
          end
          _const = @local_invocation_resources.const_cache[ _stem ]
        when 1
          _const = NOTHING_  # hi. :#here2
        else
          self._ARGUMENT_ERROR__need_one_or_two_pieces__
        end

        LazyLoadableReference_for_ModelProbably___.define do |o|
          o.glob_resources = @glob_resources
          o.local_invocation_resources = @local_invocation_resources
          o.single_element_const_path = s_a
          o.sub_branch_const = _const
        end
      end
    end

#=== BEGIN LEGACY

    class LEGACY_Brazen_Actionesque_ProduceBoundCall

      attr_reader(
        :argument_scanner,
        :current_bound,
      )

      attr_writer(
        :module,  # just for resolving some event handler when necessary
        :argument_scanner,
        :current_bound,
        :unbound_stream,
      )

      def initialize k, & oes_p
        @current_bound = nil
        @subject_unbound = k
        @on_event_selectively = oes_p
        @mutable_box = nil
      end

      def iambic= x_a

        if :on_event_selectively == x_a[ -2 ]  # #[#br-049] case study: ordering hacks
          oes_p = x_a[ -1 ]
          x_a[ -2, 2 ] = EMPTY_A_
        end

        if oes_p
          @on_event_selectively = oes_p
        end

        @argument_scanner = Common_::Scanner.via_array x_a
        NIL_
      end

      def mutable_box= bx

        oes_p = bx.remove :on_event_selectively do end
        if oes_p
          @on_event_selectively = oes_p
        end
        @mutable_box = bx
        NIL_
      end

      def execute

        @on_event_selectively ||= __produce_some_handle_event_selectively

        _ok = __resolve_bound
        _ok && __via_bound_produce_bound_call
      end

      def __resolve_bound

        if @argument_scanner.unparsed_exists

          @unbound_stream = @subject_unbound.build_unordered_selection_stream(
            & @on_event_selectively )

          __parse_arugument_stream_against_unbound_stream
        else
          __whine_about_how_there_is_an_empty_iambic_arglist
        end
      end

      def __whine_about_how_there_is_an_empty_iambic_arglist
        _end_in_error_with :no_such_action, :action_name, nil
      end

      def __parse_arugument_stream_against_unbound_stream

        begin

          ok = find_via_unbound_stream
          ok or break

          if ! @current_bound.is_branch
            break
          end

          if @argument_scanner.no_unparsed_exists
            __when_name_is_too_short
            ok = false
            break
          end

          @unbound_stream = @current_bound.to_unordered_selection_stream

          redo
        end while nil
        ok
      end

      def find_via_unbound_stream  # resolves current_bound. results in t/f

        st = @unbound_stream
        sym = @argument_scanner.head_as_is

        begin

          unb = st.gets
          unb or break

          if sym == unb.name_function.as_lowercase_with_underscores_symbol
            @argument_scanner.advance_one
            break
          end

          redo
        end while nil

        if unb

          bnd = @current_bound
          @current_bound = unb.new @subject_unbound, & @on_event_selectively
          if bnd
            @current_bound.accept_parent_node bnd
          end
          ACHIEVED_
        else
          __when_no_bound_at_this_step
        end
      end

      def __when_no_bound_at_this_step
        _end_in_error_with :no_such_action, :action_name, @argument_scanner.head_as_is
      end

      def __when_name_is_too_short
        _end_in_error_with :action_name_ends_on_branch_node,
          :local_node_name, @current_bound.name.as_lowercase_with_underscores_symbol
      end

      def __via_bound_produce_bound_call

        if @mutable_box

          if @argument_scanner.unparsed_exists

            @current_bound.bound_call_against_argument_scanner_and_mutable_box(
              @argument_scanner, @mutable_box )

          else
            @current_bound.bound_call_against_box @mutable_box
          end
        else
          @current_bound.bound_call_against_argument_scanner @argument_scanner
        end
      end

      def _end_in_error_with * x_a

        _result = @on_event_selectively.call :error, x_a.first do
          Common_::Event.inline_not_OK_via_mutable_iambic_and_message_proc x_a, nil
        end

        @bound_call = Common_::BoundCall.via_value _result

        UNABLE_
      end

      def __produce_some_handle_event_selectively

        _BR = LEGACY_brazen___[]

        sout, serr = _BR.lib_.system.IO.some_two_IOs

        _expag = @module.const_get( :API, false ).expression_agent_instance

        _ = Home_.lib_.zerk::
          Expresser::LEGACY_Brazen_API_TwoStreamEventExpresser

        event_expresser = _.new sout, serr, _expag

        -> * i_a, & ev_p do

          event_expresser.maybe_receive_on_channel_event i_a do
            if ev_p
              ev_p[]
            else
              Common_::Event.inline_via_normal_extended_mutable_channel i_a
            end
          end
        end
      end
    end

    # ==

    LEGACY_brazen___ = Lazy_.call do
      _BR = Autoloader_.require_sidesystem :Brazen
      _BR  # #hi. #todo
    end

    # ==
#=== END LEGACY

    BoundCallOfOpMethods__ = ::Module.new  # (re-opens)

    class LazyLoadableReference_for_ModelProbably___ < Common_::SimpleModel

      # when there's a file to load, do it late (hence "lazy").
      #
      # assume the resource represented by this loadable reference is (equivalent
      # to) the kind of node we put under `Models_`, i.e a business model.
      #
      # but it MIGHT actually be itself a terminal action (e.g our [sn] Ping),
      # we don't know until we load the file and see what things look like..

      def initialize
        yield self
        @name_symbol = @single_element_const_path.fetch(0).gsub( DASH_, UNDERSCORE_ ).intern
        @_business_module = :__business_module_initially
      end

      attr_writer(
        :glob_resources,
        :local_invocation_resources,
        :single_element_const_path,
        :sub_branch_const,
      )

      include BoundCallOfOpMethods__

      def bound_call_of_operator_by  # [bs]

        # (must be reentrant - is evident if you run all tests in the file)

        mod = dereference_loadable_reference
        c = @sub_branch_const  # `Actions`, probably

        if mod.respond_to? :const_get
          if mod.const_get c, false
            do_this = :__branchy
          else
            do_this = :__action  # as described [#here.3], this is how we
            # hack having an action "sitting" in a spot where a model is
            # supposed to go.  :[#008.4] #borrow-coverage from [sn]
          end
        else
          c && self._SANITY__if_you_want_to_use_a_proc_in___
          do_this = :__proc
        end

        rh = ResourcerAndHooks__.define do |o|
          yield o  # hi.
        end

        case do_this
        when :__branchy

          BoundCall_via_Branch___.call_by do |o|
            o.business_module = mod
            o.glob_resources = @glob_resources
            o.local_invocation_resources = @local_invocation_resources
            o.sub_branch_const = c
            o.resourcer_and_hooks = rh
          end
        when :__action

          BoundCall_via_Action__.call_by do |o|
            o.action_class = mod
            o.local_invocation_resources = @local_invocation_resources
            o.resourcer_and_hooks = rh
          end
        when :__proc

          _rrh = rh.close_resourcey_reference
          _rr = _rrh.resourcey_reference

          ::Skylab::Zerk::MicroserviceToolkit::BoundCall_of_Operation_via_Proc.call_by do |o|

            o.invocation_stack_top_name_symbol = @name_symbol
            o.proc = mod
            o.invocation_or_resources = _rr
          end
        end
      end

      alias_method :_bound_call_of_operator_by_, :bound_call_of_operator_by

      def dereference_loadable_reference  # as used by [sn]. might rename to "derefence"
        send @_business_module
      end

      def __business_module_initially
        @_business_module = :__business_module
        @__business_module = Autoloader_.const_reduce_by do |o|
          o.from_module = @glob_resources.splay_module
          o.const_path = @single_element_const_path
          o.autoloaderize
        end
        send @_business_module
      end

      def __business_module
        @__business_module
      end

      attr_reader(
        :name_symbol,
      )

      alias_method :intern, :name_symbol  # :[#008.3] #borrow-coverage from [sn]
    end

    BoundCallByWhat__ = ::Class.new Common_::MagneticBySimpleModel  # (re-opens)

    class BoundCall_via_Branch___ < BoundCallByWhat__

      # for conventional operations. this is probably the essential
      # algorithm of the file: resolve an operator branch and use it to
      # parse the next step.

      attr_writer(
        :business_module,
        :glob_resources,
        :sub_branch_const,
      )

      def execute
        __init_things_and_operator_branch
        __fake_build_and_send_the_not_really_operation
        found = __find_operator
        if found

          # (seems like we should recurse)
            __at_endpoint found
        end
      end

      def __at_endpoint found

        _op_ref = found.mixed_business_value
        _cls = _op_ref.dereference_loadable_reference

        _x = BoundCall_via_Action__.call_by do |o|  # like #here3
          o.action_class = _cls
          o.local_invocation_resources = @local_invocation_resources
          o.resourcer_and_hooks = @resourcey_and_resourcer_and_hooks.resourcer_and_hooks
        end

        _x  # #todo
      end

      # --

      def __find_operator

        p = @resourcey_and_resourcer_and_hooks.hooks.operator_via_branch_by
        if p
          p[ self ]
        else
          __find_operator_when_branch_normally
        end
      end

      def __find_operator_when_branch_normally

        # this is codepoint :[#doc.4] (referenced by [br])

        _as = __argument_scanner

        _ob = release_operator_branch

        _omni = MTk_::ParseArguments_via_FeaturesInjections.define do |o|

          o.argument_scanner = _as

          o.add_operators_injection_by do |inj|
            inj.operators = _ob
            inj.injector = :_no_injector_for_now_from_PU_
          end
        end

        _ = _omni.parse_operator
        _  # #todo hi.
      end

      def __argument_scanner

        _rr = @resourcey_and_resourcer_and_hooks.resourcey_reference
        _irsx = _rr.remote_invocation_resources
        _as = _irsx.argument_scanner
        _as  # hi. #todo
      end

      def release_operator_branch  # (for above and API)
        remove_instance_variable :@__operator_branch
      end

      def __fake_build_and_send_the_not_really_operation

        # branchy nodes [#ze-030.3] are operators but not operations. in
        # our new simplified conception these branch nodes have no formal
        # parameters of their own, so there is no parametric state to
        # maintain, so not only do we *not* create instances of these nodes,
        # we couldn't even if we wanted to because we use modules (not
        # classes) to represent them.
        #
        # however, the client reasonably deserves to be notified of each
        # next parsed branch node through the same mechanism through which
        # we send it info about the endpoints we parse.
        #
        # this is not all just cosmetic. this is an injection point. we
        # cannot access the argument scanner we need to complete the parse
        # until the client has been given a chance to inject new resources,
        # and we can't do that until we've passed it the would-be instance.

        rh = remove_instance_variable :@resourcer_and_hooks
        ho = rh.hooks
        mod = @business_module

        ho.maybe_send_operation_module do
          mod
        end

        same = Lazy_.call do
          NotAnInstance___[ mod ]
        end

        @resourcey_and_resourcer_and_hooks = rh.close_resourcey_reference do
          same[]
        end

        ho.maybe_send_operation_instance do
          same[]
        end

        NIL
      end

      # --

      def __init_things_and_operator_branch

        @_actions_branch_module =
          @business_module.const_get @sub_branch_const, false

        @__operator_branch = if @_actions_branch_module.respond_to? :dir_path
          _gr = @glob_resources.dup_for @_actions_branch_module
          OperatorBranch_via_ACTION_Paths___.new _gr, @local_invocation_resources
        else
          OperatorBranch_via_Action_CONSTANTS___.call(
            @_actions_branch_module, @local_invocation_resources )
        end
        NIL
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

    NotAnInstance___ = ::Struct.new :the_business_module

    # ~ 2. via ACTION paths

    class OperatorBranch_via_ACTION_Paths___

      # an "actION" path is different from an "actionS" path. the first
      # represents a would-be filesystem path (actually "node path") for an
      # action node, the other represents a would-be filesystem path
      # (actually node path) for a "branch module" of several actions
      # (typically called `Actions`). we scream-case our name to emphasize
      # the distinction.
      #
      # the counterpart class for "actionS" is #here1. some copy-pasta,
      # but we are different because we don't hop 2-deep, we hop 1-deep.

      def initialize gr, lirsx

        _glob = ::File.join gr.path_head, GLOB_STAR_

        _paths = gr.filesystem.glob _glob
          # now we can "know" what the actions are of this model

        _path_scn = Scanner_[ _paths ]

        @__localize = Home_.lib_.basic::Pathname::Localizer[ gr.path_head ]

        @local_invocation_resources = lirsx
        @glob_resources = gr

        @_implementor = CachingOperatorBranch__.new _path_scn do |path|
          __build_loadable_reference_via_path path
        end
      end

      def lookup_softly k
        @_implementor._lookup_softly k
      end

      def to_loadable_reference_stream
        @_implementor._to_loadable_reference_stream
      end

      def __build_loadable_reference_via_path path

        tail = @__localize[ path ]

        tail.include? ::File::SEPARATOR and self._SANITY__should_be_one_deep__

        d = ::File.extname( tail ).length

        if d.zero?
          _stem = tail  # this occurs when the action has its own directory.
          # (in such cases consider breaking your action down into magnets
          # and models that live outside this directory.)
          # :[#008.5] #borrow-coverage from [sn]
        else
          _stem = tail[ 0 ... -d ]
        end ; tail = nil

        LazyLoadableReference_for_ActionProbably___.define do |o|
          o.glob_resources = @glob_resources
          o.local_invocation_resources = @local_invocation_resources
          o.stem = _stem
        end
      end
    end

    class LazyLoadableReference_for_ActionProbably___ < Common_::SimpleModel

      # when there's a file to load, do it late (hence "lazy").
      #
      # assume the resource represented by this loadable reference is (equivalent
      # to) the kind of node we put under `Actions`, i.e an action.

      def initialize
        yield self
        @_action_module = :__action_module_initially
        @name_symbol = @stem.gsub( DASH_, UNDERSCORE_ ).intern
      end

      attr_writer(
        :glob_resources,
        :local_invocation_resources,
        :stem,
      )

      include BoundCallOfOpMethods__

      def _bound_call_of_operator_by_
        _rh = ResourcerAndHooks__.define do |o|
          yield o
        end
        BoundCall_via_Action__.call_by do |o|  # :#here3
          o.action_class = _action_module
          o.local_invocation_resources = @local_invocation_resources
          o.resourcer_and_hooks = _rh
        end
      end

      def dereference_loadable_reference
        _action_module
      end

      def _action_module
        send @_action_module
      end

      def __action_module_initially
        @_action_module = :__action_module
        @__action_module = Autoloader_.const_reduce_by do |o|
          o.from_module = @glob_resources.splay_module
          o.const_path = [ @stem ]
          o.autoloaderize
        end
        send @_action_module
      end

      def __action_module
        @__action_module
      end

      attr_reader(
        :name_symbol,
      )

      alias_method :intern, :name_symbol  # :[#008.2] #borrow-coverage from [sn]
    end

    # ~ 3. via action CONSTANTS

    OperatorBranch_via_Action_CONSTANTS___ = -> splay, lirsx do

      # much less moving parts because the constants (nodes) are already loaded

      # -
        Home_.lib_.basic::Module::OperatorBranch_via_Module.define do |o|
          o.module = splay
          o.loadable_reference_by = -> const do
            AlreadyLoadedLoadableReference___.new const, splay, lirsx
          end
        end
      # -
    end

    class AlreadyLoadedLoadableReference___

      def initialize const, splay, lirsx

        @name_symbol = Common_::Name.via_const_symbol( const ).
          as_lowercase_with_underscores_symbol

        @__const = const
        @__local_invocation_resources = lirsx
        @__splay = splay
      end

      include BoundCallOfOpMethods__

      def _bound_call_of_operator_by_
        _cb = ResourcerAndHooks__.define do |o|
          yield o
        end
        _cls = dereference_loadable_reference
        BoundCall_via_Action__.call_by do |o|
          o.action_class = _cls
          o.local_invocation_resources = @__local_invocation_resources
          o.resourcer_and_hooks = _cb
        end
      end

      def dereference_loadable_reference
        @__splay.const_get @__const, false
      end

      attr_reader(
        :name_symbol,
      )
    end

    module BoundCallOfOpMethods__  # (re-open)
      def bound_call_of_operator_via_invocation invo  # [br]
        _bound_call_of_operator_by_ do |o|
          o.remote_invocation = invo
        end
      end
      def bound_call_of_operator_via_invocation_resouces irsx  # [bs] [sn]
        _bound_call_of_operator_by_ do |o|
          o.remote_invocation_resources = irsx
        end
      end
    end

    # == section 3 of 3 - support (shared)

    class CachingOperatorBranch__

      def initialize scn, & p
        @_cached_loadable_reference_via_normal_name = {}
        @_lookup = :__lookup_when_open
        @_splay = :__splay_when_open
        @_open = true

        @_path_scanner = scn
        @__reference_via_path = p
      end

      # -- exposures (all local)

      def _lookup_softly k
        send @_lookup, k
      end

      def _to_loadable_reference_stream
        send @_splay
      end

      # -- lookup

      def __lookup_when_open k
        lt = @_cached_loadable_reference_via_normal_name[ k ]
        if lt ; lt ; else
          __lookup_non_cached k
        end
      end

      def __lookup_non_cached k
        begin
          reference = _gets_reference
          if k == reference.name_symbol
            found = true
            break
          end
        end while @_open
        found && reference
      end

      def __lookup_when_closed k
        @_cached_loadable_reference_via_normal_name[ k ]
      end

      # -- splay

      def __splay_when_open

        if @_cached_loadable_reference_via_normal_name.length.zero?
          _to_remaining_live_splay
        else
          __to_hybrid_splay
        end
      end

      def __to_hybrid_splay

        # "in nature" this doesn't happen unless (e.g) in [sn] you running
        # multiple test files, leading to the reuse of the same microservice
        # operator branch across several invocations

        Common_::Stream::CompoundStream.define do |o|

          o.add_stream _splay_of_cached

          o.add_stream_by( & method( :_to_remaining_live_splay ) )
        end
      end

      def _to_remaining_live_splay
        Common_.stream do
          @_open && _gets_reference
        end
      end

      def _splay_of_cached
        Stream_[ @_cached_loadable_reference_via_normal_name.values ]
      end

      # -- support

      def _gets_reference

        _path = @_path_scanner.gets_one

        reference = @__reference_via_path[ _path ]

        if @_path_scanner.no_unparsed_exists
          __close
        end

        @_cached_loadable_reference_via_normal_name[ reference.name_symbol ] = reference
        reference
      end

      def __close
        @_lookup = :__lookup_when_closed
        @_splay = :_splay_of_cached
        remove_instance_variable :@_path_scanner
        remove_instance_variable :@__reference_via_path
        @_open = false
        freeze
      end
    end

    # ==

    class BoundCall_via_Action__ < BoundCallByWhat__

      attr_writer(
        :action_class,
      )

      def execute

        op = __build_operation

        if op.respond_to? :to_bound_call_of_operator

          op.to_bound_call_of_operator

        elsif op.respond_to? :definition

          rrh = @resourcey_and_resourcer_and_hooks
          ho = rrh.hooks

          _less_things = Details__.new(
            ho.customize_normalization_by,
            ho.inject_definitions_by,
            op,
            rrh.resourcey_reference,
          )
          @local_invocation_resources.
            bound_call_when_operation_with_definition_by[ _less_things ]

        else
          Common_::BoundCall.by( & op.method( :execute ) )
        end
      end

      def __build_operation

        rh = remove_instance_variable :@resourcer_and_hooks
        cls = @action_class
        ho = rh.hooks

        ho.maybe_send_operation_module do
          cls
        end

        op = cls.allocate

        rrh = rh.close_resourcey_reference do
          op
        end

        op.send :initialize do
          rrh.resourcey_reference.value
        end

        ho.maybe_send_operation_instance do
          op
        end

        @resourcey_and_resourcer_and_hooks = rrh

        op
      end
    end

    Details__ = ::Struct.new(
      :customize_normalization_by,
      :inject_definitions_by,
      :operation,
      :invocation_or_resources,
    )

    # ~

    class BoundCallByWhat__  # (re-open)

      attr_writer(
        :local_invocation_resources,
        :resourcer_and_hooks,
      )
      attr_reader(
        :resourcer_and_hooks,
      )
    end

    class ResourcerAndHooks__ < Common_::SimpleModel  # exactly [#doc.C]

      def initialize
        @hooks = Hooks___.new
        @__mutex_for_resourcey_reference = nil
        super
        @hooks.freeze
      end

      def remote_invocation_resources_by= p
        _recv_resourcey_reference ResourceyReferenceRsxProc___.new p ; p
      end

      def remote_invocation= x
        _recv_resourcey_reference ResourceyReferenceInvoValue___.new x ; x
      end

      def remote_invocation_resources= x
        _recv_resourcey_reference ResourceyReferenceRsxValue__.new x ; x
      end

      def _recv_resourcey_reference rr
        remove_instance_variable :@__mutex_for_resourcey_reference
        @__resourcey_reference = rr ; nil
      end

      # --

      def customize_normalization_by= p
        @hooks.customize_normalization_by = p
      end

      def inject_definitions_by= p
        @hooks.inject_definitions_by = p
      end

      def operator_via_branch_by= p
        @hooks.operator_via_branch_by = p
      end

      def receive_operation_by= p
        @hooks.receive_operation_by = p
      end

      def receive_operation_module_by= p
        @hooks.receive_operation_module_by = p
      end

      # --

      def close_resourcey_reference

        _use_resourcey = @__resourcey_reference.close_by do
          yield
        end

        ResourceyAndResourcerAndHooks___.new _use_resourcey, self
      end

      attr_reader(
        :hooks,
      )
    end

    class ResourceyAndResourcerAndHooks___

      def initialize rr, rh
        @resourcey_reference = rr
        @resourcer_and_hooks = rh
      end

      def hooks
        @resourcer_and_hooks.hooks
      end

      attr_reader(
        :resourcer_and_hooks,
        :resourcey_reference,
      )
    end

    class Hooks___

      def initialize
        @customize_normalization_by = nil
        @inject_definitions_by = nil
        @operator_via_branch_by = nil
        @receive_operation_by = nil
        @receive_operation_module_by = nil
      end

      attr_accessor(
        :customize_normalization_by,
        :inject_definitions_by,
        :operator_via_branch_by,
        :receive_operation_by,
        :receive_operation_module_by,
      )

      def maybe_send_operation_instance
        p = @receive_operation_by
        if p
          _op = yield
          p[ _op ]
        end
        NIL
      end

      def maybe_send_operation_module
        p = @receive_operation_module_by
        if p
          _op_mod = yield
          p[ _op_mod ]
        end
        NIL
      end
    end

    ProcBased__ = ::Class.new ; ValueBased__ = ::Class.new
    InvoMethods__ = ::Module.new ; ResourcesMethods__ = ::Module.new

    class ResourceyReferenceRsxProc___ < ProcBased__

      include ResourcesMethods__

      def close_by
        _op = yield
        _xx = @_proc_[ _op ]
        ResourceyReferenceRsxValue__.new _xx
      end

      def name_symbol
        :_invocation_resources_PL_
      end
    end

    class ResourceyReferenceInvoValue___ < ValueBased__
      include InvoMethods__
      def name_symbol
        :_invocation_PL_
      end
    end

    class ResourceyReferenceRsxValue__ < ValueBased__
      include ResourcesMethods__
      def name_symbol
        :_invocation_resources_PL_
      end
    end

    class ProcBased__

      def initialize p
        @_proc_ = p
      end
    end

    class ValueBased__

      def initialize x
        @value = x
        freeze
      end

      def close_by
        self
      end

      attr_reader :value
    end

    module InvoMethods__

      def remote_invocation_resources
        @value.invocation_resources
      end
    end

    module ResourcesMethods__

      def remote_invocation_resources
        @value
      end
    end

    # ==

    class GlobResources___

      def initialize mod, fs
        _init_via_module mod
        @filesystem = fs
      end

      def dup_for mod
        dup._init_via_module mod
      end

      def _init_via_module mod
        @path_head = mod.dir_path
        @splay_module = mod ; self
      end

      attr_reader(
        :filesystem,
        :path_head,
        :splay_module,
      )
    end

    # ==

    class LocalInvocationResources___

      # so called because it is a discrete, shared set of resources meant to
      # last through the whole "invocation" of this whole thing that is happening
      # not to be confused with what the client application usually calls
      # "invocation reources", which is a fully remote concern.

      def initialize p, fs

        @const_cache = ::Hash.new do |h, k|
          x = k.split( DASH_ ).map { |s| s[0].upcase << s[1..-1] }.join.intern
          h[k] = x ; x  # always "actions" => `Actions` (maybe `Operations`)
        end

        @bound_call_when_operation_with_definition_by = p
        @filesystem = fs
      end

      attr_reader(
        :bound_call_when_operation_with_definition_by,
        :const_cache,
      )
    end

    # ==

    Require_these___ = Lazy_.call do
      Zerk_ = Home_.lib_.zerk
      MTk_ = Zerk_::MicroserviceToolkit ; nil
    end

    # ==

    GLOB_STAR_ = '*'
    Scanner_ = Common_::Scanner.method :via_array

    # ==
  end
end
# #history: moved from [br] to [pl] for substantial reconception (splicing)
