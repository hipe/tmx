module Skylab::TanMan

  # ~ the stack

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

  Stubber_ = -> model do

    -> action_const do

      Stub_.new action_const do | boundish, & oes_p |

        model::Actions__.const_get( action_const, false ).new boundish, & oes_p
      end
    end
  end

  class Stub_

    def initialize action_const, & build_bound_p

      @build_bound_p = build_bound_p
      @name_function = Callback_::Name.via_const action_const
    end

    attr_reader :name_function

    def is_actionable
      true
    end

    def is_promoted
      false
    end

    def is_branch
      false
    end

    def new boundish, & oes_p
      @build_bound_p.call boundish, & oes_p
    end

    def name
      fail  # this is only here to exist as a method, to make it look like a module
    end
  end

  DESC_METHOD_ = -> s = nil, & p do
    if s && ! p
      self.description_block = -> y { y << s }
    elsif p
      self.description_block = p
    end ; nil
  end

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
          build_OK_event_with :ping_from_action, :name_i,
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

      def receive_stdout_ x
        @stdout = x
        nil
      end

      attr_reader :stdout

      self
    end
  end

  class Model_ < Brazen_::Model_

    define_singleton_method :desc, DESC_METHOD_

    class << self

      def action_class
        Action_
      end

      def autoload_actions

        class << self

          def to_upper_unbound_action_stream
            Callback_::Stream.via_item self
          end

          def to_lower_unbound_action_stream  # #hook-in [br]
            @did_load_actions ||= begin
              self.const_get :Actions, false
              true
            end
            super
          end
        end
      end

      def entity_module
        Entity_
      end
    end
  end

  class Kernel_ < Brazen_::Kernel_  # :[#083].
    # :+#archive-tombstone: this used to be bottom properties frame
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
    end

    COMMON_PROPERTIES___ = make_common_properties do | sess |

      otr = Brazen_::Models_::Workspace.common_properties
      sess.edit_entity_class(
        :property_object, otr.fetch( :config_filename ),
        :property_object, otr.fetch( :max_num_dirs ),
        :property_object, otr.fetch( :workspace_path ) )

    end

    Actions = ::Module.new

    class Actions::Status < Brazen_::Models_::Workspace::Actions::Status

      extend Action_::MM

      @is_promoted = true

      @after_name_symbol = :init

    desc "show the status of the config director{y|ies} active at the path"

      def receive_stdout_ _
      end
    end

    class Actions::Init < Brazen_::Models_::Workspace::Actions::Init

      extend Action_::MM

      @is_promoted = true

      desc do |y|
        _ = @kernel.silo( :workspace ).model_class.default_config_filename
        y << "create the #{ val _ } directory"
      end

      def receive_stdout_ _
      end
    end

    class Actions::Ping < Action_

      Entity_.call self,

          :promote_action,

          :desc, -> y do
            y << "pings tanman (lowlevel)"
          end

      def produce_result
        maybe_send_event :info, :ping do
          bld_ping_event
        end
        :hello_from_tan_man
      end

      def bld_ping_event
        an = @kernel.app_name.gsub DASH_, SPACE_
        build_neutral_event_with :ping do |y, o|
          y << "hello from #{ an }."
        end
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

  class Models_::Remote < Model_

    desc "manage remotes."

    @after_name_symbol = :graph

    Actions = ::Module.new

  end

  class Models_::Graph < Model_

    @after_name_symbol = :init

    desc "with the current graph.."

    autoload_actions

    # desc "there's a lot you can tell about a man from his choice of words"
  end

  class Models_::Node < Model_::Document_Entity

    @after_name_symbol = :hear

    desc do |y|
      y << "view and edit nodes"
    end

    autoload_actions

    class << self
      def touch
        self::Actors__::Mutate::Touch
      end
    end

    def to_controller  # experiment
      Models_::Node::Controller__.new self, @preconditions.fetch( :dot_file )
    end

    attr_reader :node_stmt

    Node_ = self
  end

  class Models_::Association < Model_::Document_Entity

    @after_name_symbol = :node

    desc do |y|
      y << "view and edit associations"
    end

    autoload_actions
  end

  class Models_::Meaning < Model_::Document_Entity

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

    Stub_ = Stubber_[ self ]  # :+[#br-043] magic name

    module Actions
      Add = Stub_[ :Add ]
      Ls  = Stub_[ :Ls ]
      Rm = Stub_[ :Rm ]
      Associate = Stub_[ :Associate ]
    end
  end

  class Models_::Starter < Model_

    @after_name_symbol = :meaning

    desc do | y |
      y << "get or set the starter file used to create digraphs"
    end

    autoload_actions
  end

  module Models_::Datastores

    Actions = ::Module.new

    module Nodes

      Git_Config = Brazen_::Data_Stores_::Git_Config

    end
  end

  Models_::Paths = -> path, verb, call do
    Models_::Internal_::Paths[ path, verb, call ]
  end
end
