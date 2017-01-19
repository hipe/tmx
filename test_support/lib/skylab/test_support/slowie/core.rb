module Skylab::TestSupport

  class Slowie  # intro at [#025]

    module API ; class << self

      def call * a, & listener

        Require_zerk_[]

        _as = Zerk_::API::ArgumentScanner.via_array a, & listener

        _invo = begin_invocation_by _as do |api|

          api.test_file_name_pattern_by do
            Home_::Init.test_file_name_pattern
          end
        end

        bc = _invo.to_bound_call_of_operator

        if bc
          bc.receiver.send bc.method_name, * bc.args, & bc.block
        else
          UNABLE_  # "downgrading" all `nil` to false saves typing in operations
        end
      end

      def begin_invocation_by as, & givens
        API_Invocation___.new givens, as
      end
    end ; end  # >>

    API_Invocation___ = self

    def initialize givens, scn

      givens[ self ]

      @argument_scanner = scn
      @listener = scn.listener

      __init_operator_branch
    end

    def test_file_name_pattern_by & p
      @__test_file_name_pattern_by = p ; nil
    end

    # -- ad-hoc operation routing

    def to_bound_call_of_operator
      if @argument_scanner.no_unparsed_exists
        self._COVER_ME_no_arguments
      else
        __to_bound_call_when_arguments
      end
    end

    def __to_bound_call_when_arguments

      item_of_compound_branch = @argument_scanner.match_branch(
        :primary, :value, :against_branch, @_operator_branch )

      if item_of_compound_branch

        ro = item_of_compound_branch.mixed_user_value  # #here

        send ro.bound_call_method_name, ro
      end
    end

    # ~

    def __didactics_for_class_based_operation dida, ro

      cls = ro.operation_class

      dida.is_branchy = false

      dida.description_proc = cls::DESCRIPTION

      dida.description_proc_reader = cls::DESCRIPTIONS

      dida.item_normal_tuple_stream_by = -> do
        h = cls::PRIMARIES
        if h
          Stream_.call h.keys do |sym|
            [ :primary, sym ]
          end
        else
          self._FOLLOW
        end
      end
    end

    def __didactics_for_method_based_operation dida, ro

      dida.is_branchy = false

      dida.description_proc = _desc_proc_for_method_based_operation( ro )

      dida.description_proc_reader = -> k do
        ::Kernel._K  # no primaries yet for ping
      end

      dida.item_normal_tuple_stream_by = -> do
        ::Kernel._K
        NOTHING_
      end
    end

    # ~

    def __description_proc_for_class_based_operation ro
      ro.operation_class::DESCRIPTION
    end

    def _desc_proc_for_method_based_operation ro
      method ro.description_proc_method_name
    end

    # ~

    def __bound_call_for_class_based_operation ro

      @argument_scanner.advance_one

      _class = ro.operation_class

      op = _class.new { self }  # any resources operator needs, it must ask

      _emit_operator_resolved ro do |frame|
        frame.name = ro.name
        frame.operator_instance = op
      end

      Common_::BoundCall.via_receiver_and_method_name op, :execute
    end

    def __bound_call_for_method_based_operation ro

      _emit_operator_resolved ro do |frame|
        frame.name_symbol = @argument_scanner.current_primary_symbol
        frame.operator_instance = :_ts_not_a_class_based_operation_  # in case you ask
      end

      Common_::BoundCall.via_receiver_and_method_name self, ro.invocation_method_name
    end

    def _emit_operator_resolved ro

      # tell the remote client that we have resolved an operator (necessary
      # for help screens, for other reflection of current operator instance)

      @listener.call :data, :operator_resolved do |frame|

        frame.argument_scanner = @argument_scanner

        frame.define_didactics_by do |dida|
          send ro.didactics_method_name, dida, ro
        end

        yield frame
      end
      NIL
    end

    # -- particular method-based operations

    def __describe_ping y
      y << "a minimal operation for whatever"
    end

    def __invoke_ping

      @argument_scanner.advance_one
      if ! @argument_scanner.no_unparsed_exists
        had = true
        x = @argument_scanner.head_as_is
      end

      @listener.call :info, :expression, :ping do |y|

        y << "ping: #{ self.class.name }"
        if had
          y << "(\"ping\" does not parse arguments. ignoring: #{ x.inspect } [..])"
        end
        y
      end

      :_hello_from_slowie_
    end

    # --

      if false  # reference for #open [#002] coverage

      # ~ outside the main flow: coverage specifics

      def __load_and_start_coverage_plugin_if_necessary  # [#002] ..

        d = @argv.index COVERAGE_SWITCH___
        if d
          ok = __load_and_start_the_coverage_plugin d
          ok or _when_not_OK ok
        else
          true
        end
      end

      def __load_and_start_the_coverage_plugin d

        require "#{ HERE_ }/plugins--/express-coverage"

        pu = Plugins__::Express_Coverage::Back.
          new( @resources, & @on_event_selectively )

        pu.ARGV = @argv
        pu.ARGV_coverage_switch_index = d

        pu.execute
      end

      COVERAGE_SWITCH___ = '--coverage'
      end  # if false

      # ~

    # -- boilerplate for help

    def is_branchy
      true
    end

    def description_proc_reader_for_didactics
      -> k do

        item_of_compound_branch = @_operator_branch.lookup_softly k

        if item_of_compound_branch

          ro = item_of_compound_branch.mixed_user_value  # #here

          send ro.description_method_name, ro
        else
          NOTHING_  # ick when help is injected or ..?
        end
      end
    end

    def to_item_normal_tuple_stream_for_didactics

      @_operator_branch.to_load_ticket_stream.map_by do |key_x|
        [ :primary, key_x ]
      end
    end

    # -- for operations:

    def MEDIATOR
      @___mediator ||= MEDIATOR.new
    end

    def globberer_by & defn

      # (for now we do all the work to "load" the default values even
      # if they get overwritten by the caller but meh.)

      _tfnp = @__test_file_name_pattern_by.call

      _sc = Home_.lib_.open3
      # you don't want to expose this as an option because of all the
      # craziness going on in #slo-spot-1

      Here_::Models_::Globber.prototype_by do |o|

        o.test_file_name_pattern = _tfnp

        o.system_conduit = _sc

        o.listener = @listener

        defn[ o ]
      end
    end

    def build_test_directory_collection

      _sym = @argument_scanner.current_primary_symbol
      _sym || self._SANITY
      _op_id = OperationIdentifier___.new _sym
      Here_::Models_::TestDirectoryCollection.new _op_id, self
    end

    # --

    def __init_operator_branch

      Require_zerk_[]

      lib = Zerk_::ArgumentScanner

      _ping_ob = lib::OperatorBranch_via_FREEFORM.define do |defn|
        defn.add :ping, MethodBasedRouting___.new( :__invoke_ping, :__describe_ping )
      end

      _main_ob = lib::OperatorBranch_via_AutoloaderizedModule.define do |o|
        o.module = Here_::Operations
        o.item_class = ModuleBasedRouting___
      end

      @_operator_branch = lib::OperatorBranch_via_MultipleEntities.define do |o|

        o.add_entity_and_operator_branch :_ignored_ts_, _main_ob

        o.add_entity_and_operator_branch :_ignored_ts_, _ping_ob
      end

      NIL
    end

    # --

    attr_reader(
      :argument_scanner,
      :listener,
    )

    # ==

    Parse_any_remaining_ = -> op, as do
      if as.no_unparsed_exists
        ACHIEVED_
      else
        _ = Zerk_::ArgumentScanner::Syntaxish.via_operator_branch op.operator_branch
        _.parse_all_into_from op, as
      end
    end

    DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
      if x
        instance_variable_set ivar, x ; ACHIEVED_
      else
        x
      end
    end

    # ==

    class MEDIATOR

      # tracked by [#027].
      # (because so far it's orphanic, rewrote and moved here from #tombstone-A)
      # (same with #tombstone-B the old adapter base class.)

      def receive_notification_of_intention_to_run_tests
        require 'rspec/autorun'
        NIL
      end

      def receive_notification_of_intention_to_require_only
        if ! defined? ::Rspec
          Autoloader_.require_stdlib :RSpec
        end
        NIL
      end
    end

    # ==

    DESCRIPTION_FOR_TEST_DIRECTORY_ = -> y do
      y << "add test directory in which to search for test files"
    end

    # ==

    class OperationIdentifier___

      def initialize * s_a
        @path = s_a.freeze
      end

      attr_reader(
        :path,
      )
    end

    # == (would go up) :#here

    class ModuleBasedRouting___

      def initialize sm, mod
        @module = mod
        @name = Common_::Name.via_slug sm.entry_group_head
      end

      def operation_class
        @module.const_get @name.as_camelcase_const_string, false
      end

      def didactics_method_name
        :__didactics_for_class_based_operation
      end

      def description_method_name
        :__description_proc_for_class_based_operation
      end

      def bound_call_method_name
        :__bound_call_for_class_based_operation
      end

      attr_reader(
        :name,
      )
    end

    class MethodBasedRouting___

      def initialize _, __
        @description_proc_method_name = __
        @invocation_method_name = _
      end

      attr_reader(
        :description_proc_method_name,
        :invocation_method_name,
      )

      def didactics_method_name
        :__didactics_for_method_based_operation
      end

      def description_method_name
        :_desc_proc_for_method_based_operation
      end

      def bound_call_method_name
        :__bound_call_for_method_based_operation
      end
    end

    # ==

    Stream_ = -> a, & p do
      Common_::Stream.via_nonsparse_array a, & p
    end

    # ==

    Here_ = self
  end
end
# #tombstone-C: well-rounded, linguistic expression agent
# #tombstone-B: sunset orphanic adapter base class (adpaters are [#027])
# #tombstone-A: sunset orphanic, storied "relish" adapter (b. 2013-07-03)
