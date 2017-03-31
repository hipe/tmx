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

    class << self

      def define & p
        Require_these___[]
        Define___.call_by( & p )
      end
    end  # >>

    # (N is "5")

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
        :bound_call_via_action_with_definition_by,
        :filesystem,
        :models_branch_module,
      )

      def execute

        fs = remove_instance_variable :@filesystem

        _ir = LocalInvocationResources___.new(
          remove_instance_variable( :@bound_call_via_action_with_definition_by ),
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
      # also stay close to our counterpart #here-1.

      def initialize scn, gr, lirx
        @glob_resources = gr
        @local_invocation_resources = lirx

        @__localize = Home_.lib_.basic::Pathname::Localizer[ gr.path_head ]

        @_implementor = CachingOperatorBranch__.new scn do |path|
          __build_loadable_reference_via_path path  # hi.
        end
      end

      def dereference k
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

        s_a = _tail.split ::File::SEPARATOR

        2 == s_a.length || fail  # th

        # _tail  # =>  "ping/actions", "tag/actions.rb"

        entry = s_a.pop
        d = ::File.extname( entry ).length
        if d.zero?
          _stem = entry  # "actions"
        else
          _stem = entry[ 0 ... -d ]  # "actions.rb" => "actions"  [#here.2]
        end

        _const = @local_invocation_resources.const_cache[ _stem ]

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

      def bound_call_of_operator_via_invocation invo
        _bound_call_of_operator_by do |o|
          o.remote_invocation = invo
        end
      end

      def bound_call_of_operator_via_invocation_resouces rirsx
        _bound_call_of_operator_by do |o|
          o.remote_invocation_resources = rirsx
        end
      end

      def _bound_call_of_operator_by

        # (must be reentrant - is evident if you run all tests in the file)

        mod = dereference_loadable_reference
        const = @sub_branch_const  # `Actions`, probably
        if const
          if mod.const_get const, false
            _is_conventional_model = true
          else
            NOTHING_  # as described [#here.3], this is how we hack having
            # an action "sitting" in a spot where a model is supposed to go.
            # :[#008.4] #borrow-coverage from [sn]
          end
        else
          self._WE_FORGOT__when_does_this_happen_if_ever?
        end

        if _is_conventional_model
          BoundCall_via_Branch___.call_by do |o|
            yield o  # write resources or invocation
            o.business_module = mod
            o.glob_resources = @glob_resources
            o.local_invocation_resources = @local_invocation_resources
            o.sub_branch_const = const
          end
        else
          BoundCall_via_Action__.call_by do |o|
            yield o  # ..
            o.action_class = mod
            o.local_invocation_resources = @local_invocation_resources
          end
        end
      end

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

    class BoundCall_via_Branch___ < Common_::MagneticBySimpleModel

      # for conventional operations. this is probably the essential algorithm
      # of the file: resolve an operator branch and use it to parse the next
      # step.

      def remote_invocation= invo
        @_remote_invocation_resources = :__RIR_via_invo
        @_bound_call_via_found_operator = :__bound_call_via_found_op_and_invo
        @_remote_invocation = invo
      end

      def remote_invocation_resources= rsx
        @_remote_invocation_resources = :__RIR_via_selfsame_instance
        @_bound_call_via_found_operator = :__bound_call_via_found_op_and_invo_rsx
        @_remote_invo_resources_instance = rsx
      end

      attr_writer(
        :business_module,
        :glob_resources,
        :local_invocation_resources,
        :sub_branch_const,
      )

      def execute
        __init_things_and_operator_branch
        if __find_operator
          __bound_call_via_found_operator
        end
      end

      def __bound_call_via_found_operator

        _op_ref = remove_instance_variable( :@__found_operator ).mixed_business_value
        send @_bound_call_via_found_operator, _op_ref
      end

      def __bound_call_via_found_op_and_invo op_ref

        _invo = remove_instance_variable :@_remote_invocation
        op_ref.bound_call_of_operator_via_invocation _invo
      end

      def __bound_call_via_found_op_and_invo_rsx op_ref

        _rir = remove_instance_variable :@_remote_invo_resources_instance
        op_ref.bound_call_of_operator_via_invocation_resouces _rir
      end

      # --

      def __find_operator

        _rir = send @_remote_invocation_resources

        _ob = remove_instance_variable :@__operator_branch

        _ = MTk_::ParseArguments_via_FeaturesInjections.define do |o|

          o.argument_scanner = _rir.argument_scanner

          o.add_operators_injection_by do |inj|
            inj.operators = _ob
            inj.injector = :_no_injector_for_now_from_BR_
          end
        end.parse_operator

        _store :@__found_operator, _
      end

      def __RIR_via_invo
        @_remote_invocation.invocation_resources
      end

      def __RIR_via_selfsame_instance
        @_remote_invo_resources_instance
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

    # ~ 2. via ACTION paths

    class OperatorBranch_via_ACTION_Paths___

      # an "actION" path is different from an "actionS" path. the first
      # represents a would-be filesystem path (actually "node path") for an
      # action node, the other represents a would-be filesystem path
      # (actually node path) for a "branch module" of several actions
      # (typically called `Actions`). we scream-case our name to emphasize
      # the distinction.
      #
      # the counterpart class for "actionS" is #here-1. some copy-pasta,
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

      def bound_call_of_operator_via_invocation invo

        BoundCall_via_Action__.call_by do |o|
          o.action_class = send @_action_module
          o.remote_invocation = invo
          o.local_invocation_resources = @local_invocation_resources
        end
      end

      def bound_call_of_operator_via_invocation_resouces rirsx

        BoundCall_via_Action__.call_by do |o|
          o.action_class = send @_action_module
          o.remote_invocation_resources = rirsx
          o.local_invocation_resources = @local_invocation_resources
        end
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

    # ~ 3. via action CONSTANS

    OperatorBranch_via_Action_CONSTANTS___ = -> splay, lirsx do

      # much less moving parts because the constants (nodes) are already loaded

      # -
        Zerk_::ArgumentScanner::OperatorBranch_VIA_MODULE.define do |o|
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

      def bound_call_of_operator_via_invocation invo
        _by do |o|
          o.remote_invocation = invo
        end
      end

      def bound_call_of_operator_via_invocation_resouces irsx
        _by do |o|
          o.remote_invocation_resources = irsx
        end
      end

      def _by
        BoundCall_via_Action__.call_by do |o|
          yield o
          o.action_class = @__splay.const_get @__const, false
          o.local_invocation_resources = @__local_invocation_resources
        end
      end

      attr_reader(
        :name_symbol,
      )
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

    class BoundCall_via_Action__ < Common_::MagneticBySimpleModel

      def remote_invocation= x
        @_MIXED = x
      end

      def remote_invocation_resources= x
        @_MIXED = x
      end

      attr_writer(
        :action_class,
        :local_invocation_resources,
      )

      def execute

        op = @action_class.new(){ @_MIXED }

        if op.respond_to? :to_bound_call_of_operator

          op.to_bound_call_of_operator

        elsif op.respond_to? :definition

          @local_invocation_resources.bound_call_via_action_with_definition_by[ op ]

        else
          Common_::BoundCall.by( & op.method( :execute ) )
        end
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

        @bound_call_via_action_with_definition_by = p
        @filesystem = fs
      end

      attr_reader(
        :bound_call_via_action_with_definition_by,
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
