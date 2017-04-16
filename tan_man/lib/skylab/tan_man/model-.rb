module Skylab::TanMan

  module Model_

    # ==

    # parts of the below may or may not redund with the #[#ze-002.1] as we
    # drive the dust towards settling along that strain.
    #
    # however, [tm] has been historically and continues to be the
    # application that frontiers modeling to the limit of its design, and
    # as such it would follow that things are ornate here.

    # ==

    Bound_call_via_action_with_definition = -> act do

      # (started as copy-pase of [sn]. diverged significantly for `properties`)

      # ~ hand-written map reduce:

      all_qual_item_st = Here_.__action_grammar_.stream_via_array act.definition

      p = nil
      expand_using_this = nil
      main = -> do
        begin
          qual_item = all_qual_item_st.gets
          qual_item || break
          case qual_item.injection_identifier
          when :_parameter_TM_
            x = qual_item.item ; break
          when :_branch_desc_TM_
            redo
          when :_several_props_TM_
            expand_using_this[ qual_item.item ]
            x = p[] ; break
          else
            no
          end
        end while above
        x
      end
      expand_using_this = -> st do
        p = -> do
          x = st.gets
          if x
            x
          else
            p = main
            p[]
          end
        end
      end

      p = main

      _asc_st = Common_.stream do
        p[]
      end

      # ~

      ok = MTk_::Normalization.call_by do |o|

        o.association_stream_newschool = _asc_st

        o.entity_nouveau = act

        o.will_nilify  # because of #spot1.2
      end

      if ok
        Common_::BoundCall.by( & act.method( :execute ) )
      else
        NIL  # #downgrade-from-false (covered)
      end
    end

    # ==

    define_singleton_method :__action_grammar_, ( Lazy_.call do

      # all actions will leverage our custom association subclass, even
      # those that don't need to.
      #
      # however, in order to isolate the implemetation of our custom
      # associations to their own subdomain, that happens at #spot1.1

      _param_gi = my_custom_grammatical_injection_without_custom_meta_associations_

      Home_.lib_.parse_lib::IambicGrammar.define do |o|

        o.add_grammatical_injection :_branch_desc_TM_, BRANCH_DESCRIPTION___

        o.add_grammatical_injection :_parameter_TM_, _param_gi

        o.add_grammatical_injection :_several_props_TM_, SEVERAL_PROPS___
      end
    end )

    module BRANCH_DESCRIPTION___ ; class << self

      def is_keyword k
        :branch_description == k
      end

      def gets_one_item_via_scanner scn
        scn.advance_one ; scn.gets_one
      end
    end ; end

    module SEVERAL_PROPS___ ; class << self

      def is_keyword k
        :properties == k
      end

      def gets_one_item_via_scanner scn
        scn.advance_one ; scn.gets_one
      end
    end ; end

    def self.my_custom_grammatical_injection_without_custom_meta_associations_

      _orig = __common_association_grammatical_injection
      _orig.redefine do |o|
        o.item_class = __my_custom_association_class
        # the two models (prefix, postfix) are left as-is here.
      end
    end

    define_singleton_method :__my_custom_association_class, ( Lazy_.call do

      class ApplicationSpecificCustomizedAssociation____ < _common_association_class

        attr_accessor(
          :_throughput_characteristics_,
        )

        def expresses_direction
          TRUE  # for now..
        end

        self
      end
    end )

    def self.__common_association_grammatical_injection
      _common_association_class.grammatical_injection
    end

    def self._common_association_class
      Fields_lib_[]::CommonAssociation::EntityKillerParameter
    end

    # ==

    module CommonActionMethods

      def init_action_ invo
        invo.HELLO_INVOCATION  # #todo
        @_microservice_invocation_ = invo
      end

      def with_mutable_workspace_

        # assume these variables are ours for consumption (:#spot1.2):

        _dry = remove_instance_variable :@dry_run

        _ = _with_mutable_or_immutable_workspace_MO do |o|

          o.do_this_with_mutable_workspace do |ws|
            @_mutable_workspace_ = ws
            x = yield
            remove_instance_variable :@_mutable_workspace_
            x
          end

          o.is_dry_run = _dry
        end

        _ || NIL  # #downgrade-from-false
      end

      def with_immutable_workspace_

        _with_mutable_or_immutable_workspace_MO do |o|

          o.do_this_with_immutable_workspace do |ws|
            @_immutable_workspace_ = ws
            x = yield
            remove_instance_variable :@_immutable_workspace_
            x
          end
        end
      end

      def _with_mutable_or_immutable_workspace_MO

        _mnd = remove_instance_variable :@max_num_dirs_to_look
        _wsp = remove_instance_variable :@workspace_path
        _cfn = remove_instance_variable :@config_filename

        _mag = Home_.lib_.brazen_NOUVEAU::Models::Workspace::Magnetics::Workspace_via_Request
        _ = _mag.call_by do |o|

          yield o

          o.config_filename = _cfn
          o.max_num_dirs_to_look = _mnd
          o.workspace_path = _wsp
          o.filesystem = _invocation_resources_.filesystem
          o.listener = _listener_
        end

        _ || NIL  # #downgrade-from-false
      end

      def _simplified_write_ k, x
        instance_variable_set :"@#{ k }", x
        NIL
      end

      def _simplified_read_ k
        ivar = :"@#{ k }"
        if instance_variable_defined? ivar
          instance_variable_get ivar
        end
      end

      def _listener_
        _invocation_resources_.listener
      end

      def _argument_scanner_
        _invocation_resources_.argument_scanner
      end

      def _invocation_resources_
        @_microservice_invocation_.invocation_resources
      end
    end

    # ==

  if false  # for CCC
  module Common_Collection_Controller_Methods_

    # ~ :++#CC-abstraction-candidate(s)

    def one_entity_against_natural_key_fuzzily_ name_s, & oes_p

      a = __reduce_to_array_against_natural_key_fuzzily name_s, & oes_p

      a and begin
        __one_entity_via_entity_array(
          a,
          name_s,
          & oes_p )
      end
    end

    def __reduce_to_array_against_natural_key_fuzzily name_s, & oes_p

      st = to_entity_stream_via_model _model_class, & oes_p

      st and __fuzzy_reduce_to_array_stream_against_natkey st, name_s, & oes_p
    end

    def __fuzzy_reduce_to_array_stream_against_natkey st, name_s, & oes_p

      Home_.lib_.basic::Fuzzy.reduce_to_array_stream_against_string(

        st,

        name_s,

        -> ent do
          ent.natural_key_string
        end,

        -> ent do
          ent.dup
        end )
    end

    def __one_entity_via_entity_array ent_a, name_s, & oes_p

      case 1 <=> ent_a.length
      when  0
        ent_a.fetch 0
      when -1
        __one_entity_when_via_fuzzy_lookup_ambiguous ent_a, name_s, & oes_p  # #open [#012] not implemented
      when  1
        __when_zero_entities_found_against_natural_key name_s, & oes_p
      end
    end

    def __when_zero_entities_found_against_natural_key name_s, & oes_p

      oes_p ||= handle_event_selectively

      oes_p.call :error, :component_not_found do
        __build_zero_entities_found_against_natural_key_event name_s
      end

      UNABLE_
    end

    def __build_zero_entities_found_against_natural_key_event name_s

      mc = _model_class

      st = to_entity_stream_via_model mc do  # :+#hook-in
        self._HELLO
      end

      # (we used to have a `take` method on streams #tombstone-D)

      _a_few_ent_a = Common_::Stream.via_times A_FEW__ do |d|
        fly = st.gets
        fly && fly.dup
      end.to_a

      build_not_OK_event_with :component_not_found,
          :name_string, name_s,
          :a_few_ent_a, _a_few_ent_a,
          :model_class, mc do | y, o |

        human_s = o.model_class.name_function.as_human

        s_a = o.a_few_ent_a.map do |x|
          val x.natural_key_string
        end

        _some_known_nodes = case 1 <=> s_a.length
        when -1
          "(some known #{ human_s }#{ s s_a }: #{ s_a * ', ' })"
        when  0
          "(the only known #{ human_s } is #{ s_a.first })"
        when  1
          "(there are no #{ human_s }s)"
        end

        y << "#{ human_s } not found: #{
         }#{ ick o.name_string } #{
          }#{ _some_known_nodes }"

      end
    end

    A_FEW__ = 3

    def _model_class
      @model_class or self._SET_THIS_IVAR
    end
  end
  end  # if false for CCC

  if false  # for this/these model class(es)

  class Graph_Document_Entity__ < Model_

    class << self

      def action_base_class  # #hook-in to [br]'s action factory
        Home_::Model_::DocumentEntity::Action
      end

      def document_in_workspace_identifier_symbol  # #hook-out to doc.ent
        :graph
      end
    end  # >>
  end

  class Models_::Node < Graph_Document_Entity__

    @after_name_symbol = :hear

    @description_proc = -> y do
      y << "view and edit nodes"
    end

    def to_controller  # experiment
      Models_::Node::NodeController_.new self, @preconditions.fetch( :dot_file )
    end

    attr_reader :node_stmt

    Actions = stubber

    module Actions
      Add = stub
      Ls = stub
      Rm = stub
    end

    def persist_via_action action, & oes_p  # #hook-in to [br]

      entity_collection.persist_entity(
        action.argument_box,
        action.document_entity_byte_downstream_reference,
        self, & oes_p )
    end

    Here_ = self
  end

  class Models_::Association < Graph_Document_Entity__

    @after_name_symbol = :node

    @description_proc = -> y do
      y << "view and edit associations"
    end

    Actions = stubber

    module Actions
      Add = stub
      Rm = stub
    end
  end

  class Models_::Meaning < Graph_Document_Entity__

    @after_name_symbol = :association

    description_ "manage meaning"

    def initialize * a
      if 1 == a.length
        super
      else
        bx = Common_::Box.new
        bx.add :name, a.fetch( 0 )
        bx.add :value, a.fetch( 1 )
        @property_box = bx
      end
    end

    def natural_key_string
      @property_box[ :name ]
    end

    def value_string
      @property_box[ :value ]
    end

    Actions = stubber

    module Actions
      Add = stub
      Ls = stub
      Rm = stub
      Associate = stub
    end
  end

  class Models_::Starter < Model_

    self._SUNSET_THIS_CLASS  # #open [#007.D.2] (on stack)

    @after_name_symbol = :meaning

    @description_proc = -> y do
      y << "get or set the starter file used to create digraphs"
    end

    Actions = stubber

    module Actions
      Set = stub
      Ls = stub
      Get = stub
      Lines = stub

      def Lines.session * a, & p
        Models_::Starter::Actions__::Lines.session( * a, & p )
      end
    end

    def reinitialize_via_path_for_directory_as_collection path

      @property_box.replace_name_in_hash ::File.basename path
      NIL_
    end
  end
  end  # if false for this/these model class(es)

    Here_ = self
  end  # `Model_`
end
# #tombstone-E.2: "stubbing", "model" base class, "action" base class
# #tombstone-E.1: compartmentalize workspace node
# #tombstone-D: we once had `take` defined as a stream method
# #tombstone: remote add, list, rm (ancient, deprecated); check, which
# :+#tombstone: this used to be bottom properties frame
# :+#tombstone: remote model (3 lines)
