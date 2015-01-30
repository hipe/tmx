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
      self._ONLY_TO_LOOK_LIKE_A_MODULE  # #todo
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
            Callback_.stream.via_item self
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

  class Collection_Controller_ < Brazen_.model.collection_controller_class

  end

  class Kernel_ < Brazen_::Kernel_  # :[#083].
    # :+#archive-tombstone: this used to be bottom properties frame
  end

  Autoloader_[ ( Models_ = ::Module.new ), :boxxy ]

  class Models_::Workspace < Brazen_::Models_::Workspace

    self.persist_to = :datastores_git_config

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
        an = @kernel.app_name.gsub Callback_::DASH_, TanMan_::SPACE_
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

    Stub_ = Stubber_[ self ]

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
