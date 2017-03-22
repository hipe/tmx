module Skylab::TanMan

  module Model_

  if false  # to #here1
  DESCRIPTION_METHOD_ = -> s do

    self.instance_description_proc = -> y do
      y << s
    end
    NIL_
  end

  class Model_ < Brazen_::Model

    class << self
      define_method :description_, DESCRIPTION_METHOD_
      private :description_
    end  # >>

    class << self

      def action_base_class
        Action_
      end

      def entity_enhancement_module
        Entity_
      end

      def stubber
        Stub_Making_Action_Box_Module__.new self
      end

      def const_get _, __=true  # local loading hack :(
        if :Silo_Daemon == _ && ! const_defined?( :Silo_Daemon, false )
          if const_defined? :Stub_, false
            const_get :Actions__, false
          end
        end
        super
      end
    end  # >>

    Autoloader_[ self ]
  end

  # ~ this is :+[#br-065] a stubbing hack. a few notes in [#024].

  class Stub_Making_Action_Box_Module__ < ::Module

    def initialize model_class
      model_class.const_set :Stub_, :__legacy_requirement__
      @_mc = model_class
    end

    def stub
      Common_Action_Stub___.new @_mc
    end
  end

  class Action_Stub_ < ::Module

    include Brazen_.actionesque_defaults::Unbound_Methods

    def initialize & real_action_class_p
      @is_promoted = false
      @real_action_class_p = real_action_class_p
    end

    def build_unordered_selection_stream & _
      self._WHY
    end

    def build_unordered_index_stream
      # terminal nodes never expand beyond themselves
      Common_::Stream.via_item self
    end

    def name_function
      @nf ||= begin
        Common_::Name.via_module self
      end
    end

    def is_promoted= x
      # in at least one place .. eew
      @is_promoted = x
    end

    attr_reader :is_promoted

    def new boundish, & oes_p
      produce_real_action_class_.new boundish, & oes_p
    end

    def produce_real_action_class_
      @real_action_class_p.call
    end
  end

  class Common_Action_Stub___ < Action_Stub_

    def initialize sm

      @is_promoted = false
      @silo_module = sm
    end

    attr_reader(
      :silo_module,
    )

    def produce_real_action_class_
      @silo_module::Actions__.const_get @nf.as_const
    end
  end
  end  # if false :#here1

  # ~

    # a lot of this is probably redundant with (#[#ze-002.1])
    # elsewhere as we wait for dust to settle around possible etc.

    # ==

    Bound_call_via_action_with_definition = -> act do

      # (copy-paste-modify of [sn])

      _asc_st = Action_grammar___[].stream_via_array( act.definition ).map_reduce_by do |qual_item|
        if :_parameter_TM_ == qual_item.injection_identifier
          qual_item.item
        end
      end

      ok = MTk_::Normalization.call_by do |o|

        o.association_stream_newschool = _asc_st

        o.entity_nouveau = act
      end

      if ok
        Common_::BoundCall.by( & act.method( :execute ) )
      else
        NIL  # downgrade from false (covered)
      end
    end

    # ==

    Action_grammar___ = Lazy_.call do

      # for now, we built our entity/action grammar here ourself.
      # one day maybe this will become a cleaner part of a toolkit

      _param_gi = Fields_lib_[]::
        CommonAssociation::EntityKillerParameter.grammatical_injection

      _g = Home_.lib_.parse_lib::IambicGrammar.define do |o|

        o.add_grammatical_injection :_branch_desc_TM_, BRANCH_DESCRIPTION___

        o.add_grammatical_injection :_parameter_TM_, _param_gi
      end

      _g  # hi. #todo
    end

    module BRANCH_DESCRIPTION___ ; class << self

      def is_keyword k
        :branch_description == k
      end

      def gets_one_item_via_scanner scn
        scn.advance_one ; scn.gets_one
      end
    end ; end

    # ==

    module CommonActionMethods

      def init_action_ irsx
        @_invocation_resources_ = irsx
      end

      def _listener_
        @_invocation_resources_.listener
      end

      def _argument_scanner_
        @_invocation_resources_.argument_scanner
      end

      def _read_ k
        ivar = :"@#{ k }"
        if instance_variable_defined? ivar
          instance_variable_get ivar
        end
      end

      def _write_ k, x
        instance_variable_set :"@#{ k }", x
        NIL
      end
    end

    # ==


    # ==
  if false  # to #here2
  class Action_ < Brazen_::Action

    extend( module MM

      define_method :description_, DESCRIPTION_METHOD_
      private :description_

      def entity_enhancement_module
        Entity_
      end

      self
    end )

    include module IM

      def bound_call_for_ping_

        Common_::BoundCall.by do

          sym = name.as_lowercase_with_underscores_symbol

          ___maybe_send_ping_event sym

          :"ping_from__#{ sym }__"
        end
      end

      def ___maybe_send_ping_event sym

        maybe_send_event :payload, :ping_from_action do

          _ = build_OK_event_with(
            :ping_from_action,
            :name_symbol, sym,
          )
          _
        end
      end

      def receive_extra_values_event ev  # #hook-in [cb]
        maybe_send_event :error do
          ev
        end
        UNABLE_  # important - the above is unreliable
      end

      def krnl
        @kernel
      end

      def receive_stdin_ x
        @stdin_ = x
        nil
      end

      def receive_stdout_ x
        @stdout_ = x
        nil
      end

      attr_reader :stdin_, :stdout_

      def to_qualified_knownness_box__

        bx = Common_::Box.new
        fo = formal_properties

        ( @argument_box.each_pair do | k, x |

          bx.add k, Common_::Qualified_Knownness.via_value_and_association( x, fo.fetch( k ) )

        end )
        bx
      end

      self
    end
  end

  Entity_ = Brazen_::Modelesque.entity do

    # create an entity extension module whose foundation is another entity
    # extension module. effectively we inherit its metaproperties & ad-hoc
    # processors, etc. we may add to them but not (easily) take them away.

  end

  module Entity_

  public

    def property_value_via_symbol sym  # abstraction candidate
      property_value_via_property self.class.properties.fetch sym
    end

    def receive_missing_required_properties_event ev  # #hook-in [br]
      receive_missing_required_properties_softly ev  # #experimental
      UNABLE_
    end
  end

  Actor_ = -> cls, * a do
    self._WHERE__see_patch__

    Home_.lib_.fields::Attributes::Actor.via cls, a

    Common_::Event.selective_builder_sender_receiver cls ; nil
  end

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

  Silo_daemon_base_class_ = -> do
    Brazen_::Silo::Daemon
  end

  # ~

  module Models_

    Autoloader_[ self, :boxxy ]

    # old autoloader used to fall back to loading the lexically lowest file.
    # that weirdness has been simplified away so now we must state the below
    # explicitly. ugly until the next rearchitecting at #open [#096]

    stowaway :Comment, 'comment/line-stream'
    stowaway :Internal, 'internal/paths'
  end

  if false  # #todo: cut this soon
  class Models_::Workspace < Brazen_::Models_::Workspace

    set_workspace_config_filename 'tanman-workspace/config'

    class << self

      def common_properties
        COMMON_PROPERTIES___
      end

      def entity_enhancement_module
        Entity_  # for below
      end
    end  # >>

    COMMON_PROPERTIES___ = make_common_properties do | sess |

      otr = Brazen_::Models_::Workspace.common_properties

      sess.edit_common_properties_module(
        :property_object, otr.fetch( :config_filename ),
        :property_object, otr.fetch( :max_num_dirs ),
        :property_object, otr.fetch( :workspace_path ) )

    end

    Silo_Daemon = self::Silo_Daemon

    Actions = Stub_Making_Action_Box_Module__.new self

    module Actions

      Status = stub
      Status.is_promoted = true
      Init = stub
      Init.is_promoted = true
      Ping = stub
      Ping.is_promoted = true
    end

    # ~ all abstraction candidates:

    def business_property_value sym, & oes_p

      ok = resolve_document_( & oes_p )
      ok and begin
        @document_.property_value_via_symbol sym, & oes_p
      end
    end

    def from_asset_directory_absolutize_path__ path

      ad = asset_directory_

      ad && path.length.nonzero? && ::File::SEPARATOR != path[ 0 ] and begin  # etc
        ::File.expand_path path, ad
      end
    end

    def from_asset_directory_relativize_path__ path

      ad = asset_directory_

      if ad && path && path.length.nonzero?

        Path_lib_[]::Relative_path_from[ path, ad ]
      end
    end

    def asset_directory_
      @___did_calculate_asset_dir ||= begin
        if @_surrounding_path_exists
          @__asset_dir = ::File.dirname existent_config_path
          true
        end
      end
      @__asset_dir
    end
  end
  end  # if false

  class Models_::Graph < Model_

    @after_name_symbol = :init

    description_ "with the current graph.."

    Actions = stubber

    module Actions
      Use = stub
      Sync = stub
    end

    # desc "there's a lot you can tell about a man from his choice of words"

    def persist_via_action act, & oes_p

      # (the graph document is created thru a template that ultimately needs
      #  an implementer to provide the values for its variables. it "feels
      #  right" to appoint the particulr action class itself to this role.)

      act.argument_box.add :template_values_provider_, act
      super
    end
  end

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

    class << self
      def touch
        self::Actors__::Mutate::Touch
      end
    end  # >>

    def to_controller  # experiment
      Models_::Node::Controller__.new self, @preconditions.fetch( :dot_file )
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

  end  # if false #here2

  end  # `Model_`
end
# #tombstone-E.1: compartmentalize workspace node
# #tombstone-D: we once had `take` defined as a stream method
# #tombstone: remote add, list, rm (ancient, deprecated); check, which
# :+#tombstone: this used to be bottom properties frame
# :+#tombstone: remote model (3 lines)
