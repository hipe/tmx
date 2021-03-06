module Skylab::TestSupport

  class Slowie  # intro at [#025]

    module API ; class << self

      def call * a, & listener
        invocation_via_argument_array( listener, a ).execute
      end

      def invocation_via_argument_array a, & listener
        _begin_invocation.__init_via_array listener, a
      end

      def invocation_via_argument_scanner as, & givens  # 1x in UNIVERSE (at writing)
        _begin_invocation._init_via_scanner as, & givens
      end

      def _begin_invocation
        API_Invocation___.__new
      end
    end ; end

    API_Invocation___ = self

    class << self
      alias_method :__new, :new
      undef_method :new
    end  # >>

    def initialize
      NOTHING_  # hi.
    end

    def __init_via_array listener, a

      _as = Zerk_lib_[]::API::ArgumentScanner.via_array a, & listener

      _init_via_scanner _as do |api|

        api.test_file_name_pattern_by do
          Home_::Init.test_file_name_pattern
        end
      end
    end

    def _init_via_scanner scn, & givens

      givens[ self ]

      @argument_scanner = scn
      @listener = scn.listener

      __init_feature_branch
      self
    end

    def test_file_name_pattern_by & p
      @__test_file_name_pattern_by = p ; nil
    end

    def execute
      bc = to_bound_call_of_operator
      if bc
        bc.receiver.send bc.method_name, * bc.args, & bc.block
      else
        UNABLE_  # "downgrading" all `nil` to false saves typing in operations
      end
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
        :primary, :value, :against_branch, @_feature_branch )

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

        frame.argument_scanner_narrator = @argument_scanner

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

      if false  # reference for #open [#002.G] slowie coverage

      # ~ outside the main flow: coverage specifics

      def __load_and_start_coverage_plugin_if_necessary  # [#002.G] ..

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
          new( @resources, & @listener )

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

        trueish_x = @_feature_branch.lookup_softly k

        if trueish_x

          ro = trueish_x.mixed_user_value  # #here

          send ro.description_method_name, ro
        else
          NOTHING_  # ick when help is injected or ..?
        end
      end
    end

    def to_item_normal_tuple_stream_for_didactics

      @_feature_branch.to_loadable_reference_stream.map_by do |key_x|
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

    def __init_feature_branch

      lib = Zerk_lib_[]::ArgumentScanner

      _ping_fb = lib::FeatureBranch_via_FREEFORM.define do |defn|
        defn.add :ping, MethodBasedRouting___.new( :__invoke_ping, :__describe_ping )
      end

      _main_fb = lib::FeatureBranch_via_AutoloaderizedModule.define do |o|
        o.module = Here_::Operations
        o.loadable_reference_class = ModuleBasedRouting___
        o.sub_branch_const = :Action
      end

      @_feature_branch = lib::FeatureBranch_via_MultipleEntities.define do |o|

        o.add_entity_and_feature_branch :_ignored_ts_, _main_fb

        o.add_entity_and_feature_branch :_ignored_ts_, _ping_fb
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
        _ = Zerk_::ArgumentScanner::Syntaxish.via_feature_branch op.feature_branch
        _.parse_all_into_from op, as
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

      def DO_SOMETHING_WITH_CONFIG
        # NOTE before #history-B.1 we used to rely on config files.
        # currently we are experimenting with doing the config here
        # so that this works out-of-the-box more

        c = ::RSpec.configuration

        # exclude wip
        ef = c.exclusion_filter
        unless ef.empty?
          fail "we haven't decided how to reconcile this with that. config?"
        end
        c.exclusion_filter = {wip: true}

        # order defined
        c.order = :defined   # TODO we don't know if this works
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

    class ModuleBasedRouting___ < Common_::SimpleModel

      def initialize
        yield self
        # can't freeze because memoizes things lazily
      end

      def asset_reference= ar
        @name = Common_::Name.via_slug ar.entry_group_head
        NIL
      end

      attr_accessor(
        :module,
        :sub_branch_const,
      )

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

      def intern
        @intern ||= @name.as_lowercase_with_underscores_symbol
      end

      attr_reader(
        :name,
      )

      def _HELLO_LOADABLE_REFERENCE_
        NIL
      end
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

      def _HELLO_LOADABLE_REFERENCE_
        NIL
      end
    end

    # ==

    Here_ = self
  end
end
# #history-B.1: target Ubuntu not OS X
# #tombstone-C: well-rounded, linguistic expression agent
# #tombstone-B: sunset orphanic adapter base class (adpaters are [#027])
# #tombstone-A: sunset orphanic, storied "relish" adapter (b. 2013-07-03)
