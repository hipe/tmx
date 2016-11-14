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
      sct = @argument_scanner.branch_value_via_match_primary_against Primaries_hash__[]
      if sct
        send sct.bound_call_method_name, sct
      end
    end

    Primaries_hash__ = Lazy_.call do

      # like boxxy but more simplified and rigid and ad-hoc.
      # tracked by #[#ze-051] (similar elsewhere).

      h = {
        ping: ViaMethods___.new( :__invoke_ping, :__describe_ping ),
      }

      st = Here_::Operations.entry_tree.to_state_machine_stream
      begin
        sm = st.gets
        sm || break
        name = Common_::Name.via_slug sm.entry_group_head
        h[ name.as_lowercase_with_underscores_symbol ] = ViaAssetNode___.new name
        redo
      end while above
      h
    end

    ViaAssetNode___ = ::Struct.new :name do

      def didactics_method_name
        :__didactics_for_class_based_operation
      end

      def description_method_name
        :__description_proc_for_class_based_operation
      end

      def bound_call_method_name
        :__bound_call_for_class_based_operation
      end

      def has_name
        false
      end

    end

    ViaMethods___ = ::Struct.new :invocation_method_name, :description_proc_method_name do

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

    # ~

    def __didactics_for_class_based_operation y, sct

      cls = _operation_class_via_name sct.name

      y.yield :is_branchy, false

      y.yield :description_proc, cls::DESCRIPTION

      y.yield :description_proc_reader, cls::DESCRIPTIONS

      y.yield :item_normal_tuple_stream_by, -> do
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

    def __didactics_for_method_based_operation y, sct

      y.yield :is_branchy, false

      y.yield :description_proc, _desc_proc_for_method_based_operation( sct )

      y.yield :description_proc_reader, -> k do
        ::Kernel._K  # no primaries yet for ping
      end

      y.yield :item_normal_tuple_stream_by, -> do
        ::Kernel._K
        NOTHING_
      end
    end

    # ~

    def __description_proc_for_class_based_operation sct
      _operation_class_via_name( sct.name )::DESCRIPTION
    end

    def _desc_proc_for_method_based_operation sct
      method sct.description_proc_method_name
    end

    # ~

    def __bound_call_for_class_based_operation sct

      @argument_scanner.advance_one

      _class = _operation_class_via_name sct.name

      op = _class.new { self }  # any resources operator needs, it must ask

      _emit_operator_resolved sct do |y|
        y.yield :name, sct.name
        y.yield :operator_instance, op
      end

      Common_::Bound_Call.via_receiver_and_method_name op, :execute
    end

    def _operation_class_via_name name
      Here_::Operations.const_get name.as_camelcase_const_string, false
    end

    def __bound_call_for_method_based_operation sct

      _emit_operator_resolved sct do |y|
        y.yield :name_symbol, @argument_scanner.current_primary_symbol
        y.yield :operator_instance, :_ts_not_a_class_based_operation_  # in case you ask
      end

      Common_::Bound_Call.via_receiver_and_method_name self, sct.invocation_method_name
    end

    def _emit_operator_resolved sct

      # tell the remote client that we have resolved an operator (necessary
      # for help screens, for other reflection of current operator instance)

      @listener.call :data, :operator_resolved do |y|

        y.yield :argument_scanner, @argument_scanner

        y.yield :define_didactics_by, -> dida_y do
          send sct.didactics_method_name, dida_y, sct
        end

        yield y
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

    def description_proc_reader
      -> k do
        sct = Primaries_hash__[][ k ]
        if sct
          send sct.description_method_name, sct
        else
          NOTHING_  # ick when help is injected or ..?
        end
      end
    end

    def to_item_normal_tuple_stream
      Stream_.call Primaries_hash__[].keys do |sym|
        [ :primary, sym ]
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

    attr_reader(
      :argument_scanner,
      :listener,
    )

    # ==

    DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
      if x
        instance_variable_set ivar, x ; ACHIEVED_
      else
        x
      end
    end

    # ==

    # --

    if false
    class Expression_Agent___  # #todo after :+#dev cull this

      alias_method :calculate, :instance_exec

      # ~ style-related classifications

      def _curry x
        CLI_support_[]::Styling::Stylify.curry[ [ * x ] ]
      end

      def ick msg  # e.g divide
        "\"#{ msg }\""
      end

      def hdr msg  # e.g help
        ( @hdr ||= _curry :green )[ msg ]
      end

      def par x  # e.g divide

        _nm = if x.respond_to?( :ascii_only? ) || x.respond_to?( :id2name )
          Common_::Name.via_slug x
        else
          x.name
        end

        "<#{ _nm.as_slug }>"
      end

      # ~ linguistic- (and EN-) related classifications of string

      def sp_ * x_a

        x_a[ 0, 0 ] = [ :when, :syntactic_category, :sentence_phrase ]

        _fr = Home_.lib_.human::NLP::EN::Sexp.expression_session_via_sexp x_a

        _fr.express_into ""
      end

      def and_ s_a
        # #covered-by: in tree runner, list files and do counts
        Common_::Oxford_and[ s_a ]
      end

      def both x
        # #covered-by: same as above
        Home_.lib_.human::NLP::EN.both x
      end

      def indefinite_noun s
        self._WHERE
        _NLP_agent.indefinite_noun[ s ]
      end

      def or_ s_a
        Common_::Oxford_or[ s_a ]
      end

      def progressive_verb s
        _inflect_first_word s, :progressive_verb
      end

      def s * x_a
        Home_.lib_.human::NP::EN.s( * x_a )
      end

      def third_person s
        self._WHERE
        _inflect_first_word s, :third_person
      end

      def val x
        x.inspect
      end

      def _inflect_first_word s, m

        s_a = s.split SPACE_
        s_a[ 0 ] = _NLP_agent.send m, s_a.fetch( 0 )
        s_a * SPACE_
      end

      def _NLP_agent
        Home_.lib_.human::NLP::EN::POS
      end
    end
    end  # if false

      if false
      HERE_ = ::File.expand_path '..', __FILE__

      Plugins__= ::Module.new

      Tree_Runner_ = self

      UNDERSCORE_ = '_'.freeze  # we need our own because [#002]
      end  # if false

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

    # ==

    Stream_ = -> a, & p do
      Common_::Stream.via_nonsparse_array a, & p
    end

    # ==

    Here_ = self
  end
end
# #tombstone-B: sunset orphanic adapter base class (adpaters are [#027])
# #tombstone-A: sunset orphanic, storied "relish" adapter (b. 2013-07-03)
