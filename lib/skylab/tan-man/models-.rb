module Skylab::TanMan

  DESC_METHOD_ = -> s = nil, & p do
    if s && ! p
      self.description_block = -> y { y << s }
    elsif p
      self.description_block = p
    end ; nil
  end

  class Model_ < Brazen_::Model_

    define_singleton_method :desc, DESC_METHOD_

    class << self

      def action_class
        Action_
      end

      def stubber
        Stub_Making_Action_Box_Module__.new self
      end

      def entity_module
        Entity_
      end

      public :make_common_properties, :common_properties_class  # b.c doc.ent

      def const_get _, __=nil  # local loading hack :(
        if :Silo_Daemon == _ && ! const_defined?( :Silo_Daemon, false )
          if const_defined? :Stub_, false
            const_get :Actions__, false
          end
        end
        super
      end
    end  # >>
  end

  # ~ see [#024]:stubbing

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

    def initialize & real_action_class_p
      @real_action_class_p = real_action_class_p
    end

    def name_function
      @nf ||= begin
        Callback_::Name.via_module self
      end
    end

    def is_actionable
      true
    end

    def is_branch
      false
    end

    attr_accessor :is_promoted

    def new boundish, & oes_p
      produce_real_action_class_.new boundish, & oes_p
    end

    def produce_real_action_class_
      @real_action_class_p.call
    end
  end

  class Common_Action_Stub___ < Action_Stub_

    def initialize mc
      @model_class = mc
    end

    attr_reader :model_class

    def produce_real_action_class_
      @model_class::Actions__.const_get @nf.as_const
    end
  end

  # ~

  class Action_ < Brazen_::Model_::Action

    extend( module MM

    private

      define_method :desc, DESC_METHOD_

      def entity_module
        Entity_
      end

      self
    end )

    include module IM

    private

      def bound_call_for_ping
        _x = maybe_send_event :payload, :ping_for_action do
          build_OK_event_with :ping_from_action, :name_symbol,
            name.as_lowercase_with_underscores_symbol
        end
        Brazen_.bound_call.via_value _x
      end

      def receive_extra_iambic ev  # #hook-in [cb]
        maybe_send_event :error do
          ev
        end
      end

    public

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

      def to_trio_box_
        bx = Callback_::Box.new
        fo = formal_properties
        _Trio = TanMan_.lib_.basic.trio
        ( @argument_box.each_pair do | k, x |
          bx.add k, _Trio.new( x, true, fo.fetch( k ) )
        end )
        bx
      end

      self
    end
  end


  Entity_ = Brazen_.model.entity do

    # create an entity extension module whose foundation is another entity
    # extension module. effectively we inherit its metaproperties & ad-hoc
    # processors, etc. we may add to them but not (easily) take them away.

  end

  module Entity_
  public

    def property_value_via_symbol sym  # abstraction candidate
      property_value_via_property self.class.property_via_symbol sym
    end

    def receive_missing_required_properties ev  # #hook-in [br]
      receive_missing_required_properties_softly ev  # #experimental
    end
  end

  Actor_ = -> cls, * a do
    Callback_::Actor.via_client_and_iambic cls, a
    Callback_::Event.selective_builder_sender_receiver cls ; nil
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

      st = entity_stream_via_model _model_class, & oes_p

      st and __fuzzy_reduce_to_array_stream_against_natkey st, name_s, & oes_p
    end

    def __fuzzy_reduce_to_array_stream_against_natkey st, name_s, & oes_p

      TanMan_.lib_.basic::Fuzzy.reduce_to_array_stream_against_string(

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

      oes_p.call :error, :entity_not_found do
        __build_zero_entities_found_against_natural_key_event name_s
      end

      UNABLE_
    end

    def __build_zero_entities_found_against_natural_key_event name_s

      _scn = entity_stream_via_model _model_class do  # :+#hook-in
      end

      _a_few_ent_a = _scn.take A_FEW__ do |x|
        x.dup
      end

      build_not_OK_event_with :entity_not_found,
          :name_string, name_s,
          :a_few_ent_a, _a_few_ent_a,
          :model_class, _model_class do | y, o |

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

  # ~

  Autoloader_[ ( Models_ = ::Module.new ), :boxxy ]

  class Models_::Workspace < Brazen_::Models_::Workspace

    set_workspace_config_filename 'tanman-workspace/config'

    class << self
      def common_properties
        COMMON_PROPERTIES___
      end

      def entity_module  # for below
        Entity_
      end
    end  # >>

    COMMON_PROPERTIES___ = make_common_properties do | sess |

      otr = Brazen_::Models_::Workspace.common_properties
      sess.edit_entity_class(
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

      ad && path && path.length.nonzero? and begin
        ::Pathname.new( path ).relative_path_from( ::Pathname.new ad ).to_path
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

  class Models_::Graph < Model_

    @after_name_symbol = :init

    desc "with the current graph.."

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

      def action_class  # #hook-in to [br]'s action factory
        TanMan_::Model_::Document_Entity::Action
      end

      def document_in_workspace_identifier_symbol  # #hook-out to doc.ent
        :graph
      end
    end  # >>
  end

  class Models_::Node < Graph_Document_Entity__

    @after_name_symbol = :hear

    desc do |y|
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
        action.document_entity_byte_downstream_identifier,
        self, & oes_p )
    end

    Node_ = self
  end

  class Models_::Association < Graph_Document_Entity__

    @after_name_symbol = :node

    desc do |y|
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

    desc "manage meaning"

    def initialize * a
      if 1 == a.length
        super
      else
        bx = Callback_::Box.new
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

    desc do | y |
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
  end

  Models_::Paths = -> path, verb, call, & oes_p do
    Models_::Internal_::Paths[ path, verb, call, & oes_p ]
  end
end
# :+#tombstone: this used to be bottom properties frame
# :+#tombstone: remote model (3 lines)
