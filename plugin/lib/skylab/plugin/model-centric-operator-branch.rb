module Skylab::Plugin

  module ModelCentricOperatorBranch

    # this puppy was born to assuage the PLETHORA (14?) of sidesystems
    # that use the old [br] architecture, into the modern age. generally
    # it uses filesystem globbing (not `boxxy`) to get a splay of nodes..

    class << self

      def define & p
        Require_these___[]
        Define___.call_by( & p )
      end
    end  # >>

    class Define___ < Common_::MagneticBySimpleModel

      def initialize
        @_a = []
        yield self
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

        paths = []
        remove_instance_variable( :@_a ).each do |obj|
          obj.write_into_using paths, self
        end

        @const_cache = ::Hash.new do |h, k|
          x = k.split( DASH_ ).map { |s| s[0].upcase << s[1..-1] }.join
          h[k] = x ; x  # always "actions" => `Actions` (maybe `Operations`)
        end

        RecursiveProgressiveOperatorBranch__.define do |o|
          o.branch_module = remove_instance_variable :@models_branch_module
          o.path_scanner = Common_::Scanner.via_array paths
          o.topmost_local_resources = self
        end
      end

      def this_path
        @models_branch_module.dir_path
      end

      attr_reader(
        :bound_call_via_action_with_definition_by,
        :const_cache,
        :filesystem,
      )
    end

    # ==

    class ActionsModulesGlob___
      def initialize s
        @glob = s
      end
      def write_into_using y, o
        glob = ::File.join o.this_path, @glob
        a = o.filesystem.glob glob
        if a.length.zero?
          self._SANITY__this_is_probably_not_what_you_want__
        else
          y.concat a ; nil
        end
      end
    end

    # ==

    class ActionsModulePathTail___
      def initialize s
        @path_tail = s
      end
      def write_into_using y, o
        y << ::File.join( o.this_path, @path_tail )
      end
    end

    # ==

    class RecursiveProgressiveOperatorBranch__ < Common_::SimpleModel

      # only a slight variation on [#pl-012]; track it closely.

      def initialize

        yield self

        @__LT_resources = LoadTicketResources___.new @branch_module, @topmost_local_resources

        @_cache = {}
        @_lookup_softly = :__lookup_softly_initially
        @_splay = :__splay_initially
      end

      attr_writer(
        :branch_module,
        :const_cache,
        :path_scanner,
        :topmost_local_resources,
      )

      # ~ exposures

      def lookup_softly k
        send @_lookup_softly, k
      end

      def to_load_ticket_stream
        send @_splay
      end

      # ~

      def __lookup_softly_initially k
        x = @_cache[ k ]
        if x ; x ; else
          __lookup_non_cached k
        end
      end

      def __lookup_softly_normally k
        @_cache[ k ]
      end

      def __lookup_non_cached k
        found = false ; @_done = false
        begin
          ticket = _gets_ticket
          if k == ticket.name_symbol
            found = true
            break
          end
        end until @_done
        found && ticket
      end

      def __splay_initially
        @_done = false
        Common_.stream do
          _gets_ticket unless @_done
        end
      end

      def __splay_normally
        Stream_[ @_cache.values ]
      end

      def _gets_ticket

        _path = @path_scanner.gets_one

        if @path_scanner.no_unparsed_exists
          remove_instance_variable :@path_scanner
          @_lookup_softly = :__lookup_softly_normally
          @_splay = :__splay_normally
          @_done = true
        end

        ticket = @__LT_resources.build_ticket _path
        @_cache[ ticket.name_symbol ] = ticket
        ticket
      end
    end

    # ==

    class LoadTicketResources___

      def initialize mod, tlr

        @__localize = Home_.lib_.basic::Pathname::Localizer[ mod.dir_path ]

        @bound_call_via_action_with_definition_by = tlr.bound_call_via_action_with_definition_by
        @branch_module = mod
        @const_cache = tlr.const_cache
        @filesystem = tlr.filesystem
      end

      def build_ticket path

        _tail = @__localize[ path ]  # "ping/actions"
        s_a = _tail.split ::File::SEPARATOR
        2 == s_a.length || fail  # this could be arranged

        LazyLoadTicket___.new @const_cache[ s_a.pop ], s_a, self
      end

      def bound_call_via_three mod, rsx, const
        if const and mod.const_get const, false
          BoundCall_via_BranchStuff___.new( const, rsx, mod, self ).execute
        else
          __bound_call_when_terminal rsx, mod
        end
      end

      def __bound_call_when_terminal rsx, mod

        op = mod.new(){ rsx }

        if op.respond_to? :to_bound_call_of_operator
          op.to_bound_call_of_operator

        elsif op.respond_to? :definition
          @bound_call_via_action_with_definition_by[ op ]

        else
          Common_::BoundCall.by( & op.method( :execute ) )
        end
      end

      attr_reader(
        :branch_module,
      )
    end

    # ==

    class BoundCall_via_BranchStuff___  # for conventional operations

      # very close to [#pl-012] "operator branch via directories one deeper"

      def initialize const, rsx, mod, lrsx

        @__local_resources = lrsx

        @branch_module_const = const
        @class_or_module = mod
        @resources = rsx
      end

      def execute
        __init_operator_branch
        if __parse_operator
          __bound_call_via_found_operator
        end
      end

      def __bound_call_via_found_operator
        _lt = remove_instance_variable( :@__found_operator ).mixed_business_value
        _lt.bound_call_of_operator_via_resources @resources
      end

      def __parse_operator

        _ob = remove_instance_variable :@__operator_branch

        _ = MTk_::ParseArguments_via_FeaturesInjections.define do |o|

          o.argument_scanner = @resources.argument_scanner

          o.add_operators_injection_by do |inj|
            inj.operators = _ob
            inj.injector = :_no_injector_for_now_from_BR_
          end
        end.parse_operator

        _store :@__found_operator, _
      end

      def __init_operator_branch

        @branch_module = @class_or_module.const_get @branch_module_const, false

        _ = if @branch_module.respond_to? :dir_path
          __operator_branch_recursively
        else
          __operator_branch_via_module
        end
        @__operator_branch = _ ; nil
      end

      def __operator_branch_via_module

        _lrx = remove_instance_variable :@__local_resources

        Zerk_::ArgumentScanner::OperatorBranch_VIA_MODULE.define do |o|
          o.module = @branch_module
          o.load_ticket_by = -> const do
            AlreadyLoadedLoadTicket___.new const, @branch_module, _lrx
          end
        end
      end

      def __operator_branch_recursively

        self._CODE_SKETCH_

        _glob = ::File.join @branch_module.dir_path, GLOB_STAR_
        _paths = @local_resources.filesystem.glob _glob

        RecursiveProgressiveOperatorBranch__.define do |o|
          o.branch_module = xxx
          o.const_cache = @const_cache
          o.local_resources = @local_resources
          o.path_scanner = Common_::Scanner.via_array _paths
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    end

#=== BEGIN LEGACY

    class LEGACY_Brazen_Actionesque_ProduceBoundCall

      attr_reader(
        :argument_stream,
        :current_bound,
      )

      attr_writer(
        :module,  # just for resolving some event handler when necessary
        :argument_stream,
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

        @argument_stream = Common_::Scanner.via_array x_a
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

        if @argument_stream.unparsed_exists

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

          if @argument_stream.no_unparsed_exists
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
        sym = @argument_stream.head_as_is

        begin

          unb = st.gets
          unb or break

          if sym == unb.name_function.as_lowercase_with_underscores_symbol
            @argument_stream.advance_one
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
        _end_in_error_with :no_such_action, :action_name, @argument_stream.head_as_is
      end

      def __when_name_is_too_short
        _end_in_error_with :action_name_ends_on_branch_node,
          :local_node_name, @current_bound.name.as_lowercase_with_underscores_symbol
      end

      def __via_bound_produce_bound_call

        if @mutable_box

          if @argument_stream.unparsed_exists

            @current_bound.bound_call_against_argument_scanner_and_mutable_box(
              @argument_stream, @mutable_box )

          else
            @current_bound.bound_call_against_box @mutable_box
          end
        else
          @current_bound.bound_call_against_argument_scanner @argument_stream
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

    class LazyLoadTicket___  # when there's a file to load, do it late

      def initialize const, cp, lrx

        @name_symbol = cp.fetch(0).gsub( DASH_, UNDERSCORE_ ).intern

        @_local_resources = lrx

        @const_path = cp
        @sub_branch_module_const = const
        freeze
      end

      def bound_call_of_operator_via_resources rsx

        # (must be reentrant - is evident if you run all tests in the file)

        _module = __operator_module

        @_local_resources.bound_call_via_three _module, rsx, @sub_branch_module_const
      end

      def __operator_module

        _hi = Autoloader_.const_reduce_by do |o|
          o.from_module = @_local_resources.branch_module
          o.const_path = @const_path
          o.autoloaderize
        end
        _hi  # hi. #todo
      end

      def intern
        @name_symbol
      end

      attr_reader(
        :name_symbol,
      )
    end

    class AlreadyLoadedLoadTicket___

      # NOTE you get none

      def initialize const, bm, lrx

        @name_symbol = Common_::Name.via_const_symbol( const ).
          as_lowercase_with_underscores_symbol

        @__local_resources = lrx

        @branch_module = bm
        @const = const
      end

      def bound_call_of_operator_via_resources rsx

        _lrx = remove_instance_variable :@__local_resources

        mod = @branch_module.const_get @const, false

        if mod.respond_to? :dir_path
          self._RECONSIDER
        end

        _lrx.bound_call_via_three mod, rsx, NOTHING_
      end

      attr_reader(
        :name_symbol,
      )
    end

    # ==

    Require_these___ = Lazy_.call do
      Zerk_ = Home_.lib_.zerk
      MTk_ = Zerk_::MicroserviceToolkit ; nil
    end

    # ==

    DASH_GLOB_ = '*'

    # ==
  end
end
# #history: moved from [br] to [pl] for substantial reconception (splicing)
