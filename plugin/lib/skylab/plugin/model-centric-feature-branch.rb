module Skylab::Plugin

  module ModelCentricFeatureBranch

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
    #   - section 1 of 4 - define-time
    #   - section 2 of 4 - steps
    #   - section 3 of 4 - feature branch via [3 means]
    #   - section 4 of 4 - support (shared)

    # local name convetions
    #   - `bcdv` - bound call definition values
    #   - `lirsx` - local invocation resources
    #   - `lref` - [lazy] loadable reference

    class << self

      def define & p
        Require_these___[]
        Define___.call_by( & p )
      end
    end  # >>

    # == section 1 of 4 - define-time

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

        FeatureBranch_via_ActionsPaths___.define do |o|
          o.path_scanner = Scanner_[ paths ]
          o.local_invocation_resources = _ir
          o.glob_resources = gr
        end
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

    # == section 2 of 4 - steps
    #    the purpose of a "step" object is to allow the consuming client to
    #    parse a token stream in .. steps such that at each step it can see
    #    whether this step is "branchy" or not.

    class BoundCall_via_etc_STOWAWAY___ < Common_::MagneticBySimpleModel

      #   - this whole thing is relevant to API only. logically it duplicates
      #     the comparable but more complex [#br-007.2] counterpart :[#008.6]
      #
      #   - as such it's a bit out of scope for the host file, so it's
      #     considered a stowaway.
      #
      #   - this is placed relatively high in the file because A) invocation
      #     is high level and B) so it can flow with the steps function used next
      #
      # EXPERIMENTAL - it used to be that the real call-stack would deepen
      # with the deepening of the invocation path (until a bound call was
      # produced, at which point the real stack pops back down).
      #
      # now, experimentally we instead want to do a loop-based "recursion"
      # to mimic the [#br-008.7] CLI approach :[#007.3]
      #
      # this new treatment might yield improved behavior (at a probably
      # negligible cost) because it determines the "shape" of the asset
      # discretely rather than probablistically
      #
      # currently we do *not* build an invocation stack for API ivocations
      # (we just loop). but one subscriber is interested in this (in [cu])
      # and if we made this change another subscriber would simplify (in [ba]).

      attr_writer(
        :bound_call_definition_values,
        :local_invocation_resources,
        :loadable_reference,
      )

      def execute

        bcdv = remove_instance_variable :@bound_call_definition_values
        invo_or_rsx = bcdv.invocation_or_resources
        curr_lref = remove_instance_variable :@loadable_reference

        begin
          step = STEP_VIA_LOADABLE_REFERENCE[ curr_lref ]
          unless step.is_branchy_step
            bc = if step.has_action_class
              Bound_call_via_action_class___[ step, bcdv, @local_invocation_resources ]
            else
              step.__bound_call_via_invocation_or_resources_ invo_or_rsx
            end
            break
          end
          _scn = invo_or_rsx.remote_invocation_resources.argument_scanner_narrator
          curr_lref = Step_when_branchy___[ _scn, step, curr_lref ]
        end while curr_lref
        bc
      end

      Bound_call_via_action_class___ = -> step, bcdv, lirsx do

        # (this is not a method on the step because the other mode client
        #  rolls its own, a bit more like visitor pattern)

        op = step.action_class.allocate

        op.send :initialize do
          bcdv.invocation_or_resources.value
        end

        step.bound_call_via_non_definition_based_or op do
          o = Details___.new
            o.operation = op
            o.invocation_or_resources = bcdv.invocation_or_resources
          lirsx.bound_call_when_operation_with_definition_by[ o ]
        end
      end

      Details___ = ::Struct.new(
        :operation,
        :invocation_or_resources,
      )

      Step_when_branchy___ = -> nar, step, lref do  # lref #here5

        _fb = step.BRANCHY_FEATURE_BRANCH_VIA_PARENT_FEATURE_BRANCH lref

        _omni = MTk_::ArgumentParsingIdioms_via_FeaturesInjections.define do |o|

          o.add_operators_injection_by do |inj|
            inj.operators = _fb
          end

          o.argument_scanner_narrator = nar
        end

        operator_found = _omni.procure_operator
        if operator_found
          nar.advance_past_match operator_found.operator_match  # new since the 2nd wave
          operator_found.trueish_feature_value
        end
      end
    end

    STEP_VIA_LOADABLE_REFERENCE = -> lref do
      # #open [#007.2] this is still experimental and incubating. consumer: [br]
      # -
        mixed = lref.dereference_loadable_reference

        if mixed.respond_to? :const_get

          actz = mixed.const_get lref.sub_branch_const, true  # classically `Actions`
          # (we do ascend into lexically parent modules - this could bite us, but it's useful in [sg])
          if actz
            do_this = :__branchy
          else
            do_this = :__action  # as described [#here.3], this is how we
            # hack having an action "sitting" in a spot where a model is
            # supposed to go.  :[#008.4] #borrow-coverage from [sn]
          end
        else
          do_this = :__proc
        end

        case do_this

        when :__branchy
          BranchyStep___.define do |o|
            o.actions_branch_module = actz
            o.business_module = mixed
            o.sub_branch_const = lref.sub_branch_const
          end

        when :__action
          ClassBasedActionStep___.define do |o|
            o.action_class = mixed
          end

        when :__proc
          ProcBasedActionStep__.define do |o|
            o.etc_etc_symbol = lref.name_symbol
            o.proc = mixed
          end
        end
      # -
    end

    Step__ = ::Class.new Common_::SimpleModel

    class BranchyStep___ < Step__

      attr_writer(
        :actions_branch_module,
        :sub_branch_const,
      )
      attr_accessor(
        :business_module,
      )

      def BRANCHY_FEATURE_BRANCH_VIA_PARENT_FEATURE_BRANCH lref  # #here4 or #here5
        # also #open [#007.2] still incubating, also used in [br]

        actz = @actions_branch_module

        if actz.respond_to? :dir_path

          _gr = lref.glob_resources.dup_for actz  # :#here3
          FeatureBranch_via_ACTION_Paths___.define do |o|
            o.glob_resources = _gr
            o.local_invocation_resources = lref.local_invocation_resources
            o.sub_branch_const = @sub_branch_const
          end

        elsif actz.respond_to? :call

          # FeatureBranch_via_Definition.define( & actz )  # (was)
          actz.call

        else

          # much less moving parts because the constants (nodes) are already loaded :#here6

          Home_.lib_.basic::Module::FeatureBranch_via_Module.define do |o|

            o.loadable_reference_by = -> const do

              AlreadyLoadedLoadableReference___.define do |oo|
                oo.const = const
                oo.module = actz
                oo.sub_branch_const = @sub_branch_const
              end
            end
            o.module = actz
          end
        end
      end

      def is_branchy_step
        true
      end
    end

    class ClassBasedActionStep___ < Step__

      attr_accessor(
        :action_class,
      )

      def bound_call_via_non_definition_based_or op  # [br] probably
        if op.respond_to? :to_bound_call_of_operator
          op.to_bound_call_of_operator
        elsif op.respond_to? :definition
          yield
        else
          Common_::BoundCall.by( & op.method( :execute ) )
        end
      end

      def has_action_class
        true
      end

      def is_branchy_step
        false
      end
    end

    class ProcBasedActionStep__ < Step__

      attr_writer(
        :etc_etc_symbol,
        :proc
      )

      def __bound_call_via_invocation_or_resources_ invo_or_rsx  # (we want this to become a API hook-out method #todo)

        _hot_take = MTk_::BoundCall_of_Operation_via_Proc.call_by do |o|
          o.invocation_or_resources = invo_or_rsx
          o.invocation_stack_top_name_symbol = @etc_etc_symbol
          o.proc = @proc
        end

        _hot_take  # hi. #todo
      end

      def has_action_class
        false
      end

      def is_branchy_step
        false
      end
    end

    # == section 3 of 4 - feature branch via [3 means]

    # ~ 1. via actionS paths

    class FeatureBranch_via_ActionsPaths___ < Common_::SimpleModel  # :#here4

      # very close to [#pl-012] "feature branch via directories one deeper".
      # also stay close to our counterpart #here1.

      attr_writer(
        :path_scanner,
      )
      attr_accessor(
        :glob_resources,  # #here3
        :local_invocation_resources,
      )

      def initialize
        yield self

        _scn = remove_instance_variable :@path_scanner

        @_implementor = CachingFeatureBranch__.new _scn do |path|
          __build_loadable_reference_via_path path  # hi.
        end

        @__localize = Home_.lib_.basic::Pathname::Localizer[ @glob_resources.path_head ]

        freeze
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

      def to_symbolish_reference_scanner
        @_implementor._to_symbolish_reference_scanner
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

      def initialize k, & p
        @current_bound = nil
        @subject_unbound = k
        @listener = p
        @mutable_box = nil
      end

      def iambic= x_a

        if :listener == x_a[ -2 ]  # #[#br-049] case study: ordering hacks
          p = x_a[ -1 ]
          x_a[ -2, 2 ] = EMPTY_A_
        end

        if p
          @listener = p
        end

        @argument_scanner = Common_::Scanner.via_array x_a
        NIL_
      end

      def mutable_box= bx

        p = bx.remove :listener do end
        if p
          @listener = p
        end
        @mutable_box = bx
        NIL_
      end

      def execute

        @listener ||= __produce_some_handle_event_selectively

        _ok = __resolve_bound
        _ok && __via_bound_produce_bound_call
      end

      def __resolve_bound

        if @argument_scanner.unparsed_exists

          @unbound_stream = @subject_unbound.build_unordered_selection_stream(
            & @listener )

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
          @current_bound = unb.new @subject_unbound, & @listener
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

        _result = @listener.call :error, x_a.first do
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

    class LazyLoadableReference_for_ModelProbably___ < Common_::SimpleModel  # :#here5

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
        :single_element_const_path,
      )
      attr_accessor(
        :glob_resources,
        :local_invocation_resources,
        :sub_branch_const,
      )

      # -- ( used to be spread throughout
      def bound_call_of_operator_via_invocation invo  # [br]
        _bound_call_of_operator_by do |o|
          o.remote_invocation = invo
        end
      end
      def bound_call_of_operator_via_invocation_resouces irsx  # [bs] [sn]
        _bound_call_of_operator_by do |o|
          o.remote_invocation_resources = irsx
        end
      end
      def _bound_call_of_operator_by & p
        _open_bcd = BoundCallDefinition___.define do |o|
          yield o
        end
        BoundCall_via_etc_STOWAWAY___.call_by do |o|
          o.loadable_reference = self
          o.bound_call_definition_values = _open_bcd.close_bound_call_definition  # simple town - pass nothing
          o.local_invocation_resources = @local_invocation_resources
        end
      end
      # -- )

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

    # ~ 2. via ACTION paths

    class FeatureBranch_via_ACTION_Paths___ < Common_::SimpleModel

      # an "actION" path is different from an "actionS" path. the first
      # represents a would-be filesystem path (actually "node path") for an
      # action node, the other represents a would-be filesystem path
      # (actually node path) for a "branch module" of several actions
      # (typically called `Actions`). we scream-case our name to emphasize
      # the distinction.
      #
      # the counterpart class for "actionS" is #here1. some copy-pasta,
      # but we are different because we don't hop 2-deep, we hop 1-deep.

      attr_writer(
        :glob_resources,
        :local_invocation_resources,
        :sub_branch_const,
      )

      def initialize
        yield self

        gr = @glob_resources

        _glob = ::File.join gr.path_head, GLOB_STAR_

        _paths = gr.filesystem.glob _glob
          # now we can "know" what the actions are of this model

        _path_scn = Scanner_[ _paths ]

        @__localize = Home_.lib_.basic::Pathname::Localizer[ gr.path_head ]

        @_implementor = CachingFeatureBranch__.new _path_scn do |path|
          __build_loadable_reference_via_path path
        end
        freeze
      end

      def lookup_softly k
        @_implementor._lookup_softly k
      end

      def to_loadable_reference_stream
        @_implementor._to_loadable_reference_stream
      end

      def to_symbolish_reference_scanner
        @_implementor._to_symbolish_reference_scanner
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
          o.sub_branch_const = @sub_branch_const
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
      attr_accessor(
        :sub_branch_const,
      )

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
    # (moved to #here6)


    # ~ 4. experiment [bs]

    class FeatureBranch_via_Definition < Common_::SimpleModel
      def lookup_softly_by & p
        @lookup_softly = p ; nil
      end
      def SYMBOLISH_REFERENCE_SCANNER_BY & p  # [bs]
        @to_symbolish_reference_scanner = p ; nil
      end
      # --
      def lookup_softly k
        @lookup_softly[ k ]
      end
      def to_symbolish_reference_scanner
        @to_symbolish_reference_scanner[]
      end
    end

    class AlreadyLoadedLoadableReference___ < Common_::SimpleModel

      def const= c
        @name_symbol = Common_::Name.via_const_symbol( c ).
          as_lowercase_with_underscores_symbol
        @__const = c
      end

      def module= x
        @__splay = x
      end

      attr_accessor(
        :sub_branch_const,
      )

      def dereference_loadable_reference
        @__splay.const_get @__const, false
      end

      attr_reader(
        :name_symbol,
      )
    end

    # == section 4 of 4 - support (shared)

    class CachingFeatureBranch__

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

      def _to_loadable_reference_stream  # [bs]
        self._README__either_just_convert_scanner_to_stream_or_use_scanner__
        send @_splay
      end

      def _to_symbolish_reference_scanner
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
        # feature branch across several invocations

        Common_::Scanner::CompoundScanner.define do |o|

          o.add_scanner _splay_of_cached

          o.add_scanner_by do
            _to_remaining_live_splay  # hi.
          end
        end
      end

      def _to_remaining_live_splay
        ::NoDependenciesZerk::Scanner_by.new do
          @_open && _gets_reference
        end
      end

      def _splay_of_cached
        ::NoDependenciesZerk::Scanner_via_Array.new(
          @_cached_loadable_reference_via_normal_name.values )
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

    # ~

    class BoundCallDefinition___ < Common_::SimpleModel  # exactly [#doc.C]

      def initialize
        @__mutex_for_resourcey_reference = nil
        super
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
        @__open_resourcey_reference = rr ; nil
      end

      # --

      def close_bound_call_definition

        _resourcey_reference = @__open_resourcey_reference.close_by do
          yield
        end
        BoundCallDefinitionValues___.new _resourcey_reference
      end
    end

    BoundCallDefinitionValues___ = ::Struct.new(
      :invocation_or_resources,
    )

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
        :INVOCATION_RESOURCES_SHAPE_pl
      end
    end

    class ResourceyReferenceInvoValue___ < ValueBased__
      include InvoMethods__
      def name_symbol
        :INVOCATION_SHAPE_pl
      end
    end

    class ResourceyReferenceRsxValue__ < ValueBased__
      include ResourcesMethods__
      def name_symbol
        :INVOCATION_RESOURCES_SHAPE_pl
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
# #history-A.2: during 2nd wave, stream to scanner
# #history: moved from [br] to [pl] for substantial reconception (splicing)
