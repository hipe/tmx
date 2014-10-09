module Skylab::TanMan

  # ~ the stack

  Entity_ = Brazen_::Model_::Entity[ -> do

  end ]

  module Entity_
    def receive_missing_required_properties ev
      receive_missing_required_properties_softly ev  # #experimental
    end
  end

  Actor_ = -> cls, * a do
    Callback_::Actor.via_client_and_iambic cls, a
    Event_[].sender cls ; nil
  end

  Stubber_ = -> model do
    -> i do
      Stub__.new i do |x|
        model::Actions__.const_get( i, false ).new x
      end
    end
  end

  class Stub__
    def initialize name_i, & p
      @p = p
      @name_function = Callback_::Name.from_variegated_symbol name_i
    end
    def is_actionable
      true
    end
    def is_promoted
      false
    end
    attr_reader :name_function
    def new kernel
      @p[ kernel ]
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

      define_method :desc, DESC_METHOD_

      def use_workspace_as_datastore_controller

        Entity_[ self, -> do

          o :reuse, Models_::Workspace.properties_for_reuse

        end ]

        pc_a = model_class.preconditions
        did_resolve_pcia and fail
        @did_resolve_pcia = true
        a = @preconditions = pc_a.dup
        d = a.index do |pc|
          :workspace == pc.full_name_i
        end
        if ! d
          a.push Brazen_.node_identifier.via_symbol :workspace
        end

        include Uses_Workspace_Action_Methods__

      end

      self
    end )

    include module IM

    private

      def bound_call_for_ping
        _ev = build_OK_event_with :ping_from_action, :name_i,
           name.as_lowercase_with_underscores_symbol
        x = send_event _ev
        Brazen_.bound_call -> { x }, :call
      end

      def receive_extra_iambic ev
        send_event ev
      end

      def send_event ev
        ev_ = ev.to_event
        if ev_.has_tag :ok and ! ev_.ok
          @error_count += 1
        end
        event_receiver.receive_event ev
      end

    public

      def krnl
        @kernel
      end

      def receive_event ev
        m_i = :"receive_#{ ev.terminal_channel_i }_event"
        if respond_to? m_i
          send m_i, ev
        else
          event_receiver.receive_event ev
        end
      end

    private

      def workspace_config_filename
        WS_C_FN__
      end
      WS_C_FN__ = '.tanman-workspace/conf'.freeze

      self
    end
  end

  module Uses_Workspace_Action_Methods__

    def subsume_external_arguments
      if ! @argument_box[ :workspace ] && ! @argument_box[ :config_filename ]
        a = []
        a.push @kernel.kernel_property_value :local_conf_config_name
        a.push @kernel.kernel_property_value :local_conf_dirname
        a.compact!
        if a.length.nonzero?
          @argument_box.add :config_filename, a.join( FILE_SEPARATOR_ )
        end
      end ; nil
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

          def get_unbound_upper_action_scan
            Scan_[].nonsparse_array [ self ]
          end

          def get_unbound_lower_action_scan
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

    attr_reader :error_count
  end

  class Collection_Controller_ < Brazen_.model.collection_controller

    class << self

      def use_workspace_as_dsc

        define_method :datastore_controller do

          @action.preconditions.fetch :workspace

        end
      end
    end
  end

  class Kernel_ < Brazen_::Kernel_  # :[#083].

    def kernel_property_value i
      properties_stack.property_value i
    end
  private
    def properties_stack
      @pstack ||= bld_pstack
    end
    def bld_pstack
      stack = Brazen_.properties_stack.new
      stack.push_frame Bottom_properties_frame__[]
      stack
    end
  end

  Bottom_properties_frame__ = Callback_.memoize[ -> do

    class Bottom_Properties_Frame__

      Brazen_.properties_stack.common_frame self,

        :memoized, :proc, :starter_file, -> do
          'holy-smack.dot'.freeze
        end,

        # ~ workspace resolution

        :memoized, :proc, :global_conf_path, -> do
          TanMan_::Lib_::Home_directory_pathname[].join( 'tanman-config' ).to_path
        end,

        :memoized, :proc, :local_conf_config_name, -> do
          'config'.freeze
        end,

        :memoized, :proc, :local_conf_dirname, -> do
          '.tanman-workspace'.freeze
        end,

        :memoized, :proc, :local_conf_maxdepth, -> do
          1
        end
    end

    Bottom_Properties_Frame__.new
  end ]

  Autoloader_[ ( Models_ = ::Module.new ), :boxxy ]

  class Models_::Workspace < Brazen_::Models_::Workspace

    self.persist_to = :datastores_git_config

    class << self

      def properties_for_reuse
        Xxx__[].properties.to_a
      end
      Xxx__ = -> do
        p = -> do
          class Xxx___
            Entity_[ self, -> do
              o :property, :workspace,
                :property, :workspace_path,
                :property, :config_filename
            end ]
          end
          p = -> { Xxx___ }
          Xxx___
        end
        -> { p[] }
      end.call
    end

    Actions = ::Module.new

    class Actions::Status < Brazen_::Models_::Workspace::Actions::Status

      extend Action_::MM

      self.is_promoted = true

      self.after_i = :init

    desc "show the status of the config director{y|ies} active at the path."

      def produce_any_result
      end
    end

    class Actions::Init < Brazen_::Models_::Workspace::Actions::Init

      extend Action_::MM

      self.is_promoted = true

      desc do |y|
        y << "create the #{ val property_value :local_conf_dirname } directory"
      end
    end

    class Actions::Ping < Action_

      Entity_[ self, -> do
        o :is_promoted

        o :desc, -> y do
          y << "pings tanman (lowlevel)."
        end

      end ]

      def produce_any_result
        an = @kernel.app_name.gsub Callback_::DASH_, TanMan_::SPACE_
        ev = build_neutral_event_with :ping do |y, o|
          y << "hello from #{ an }."
        end
        send_event ev
        :hello_from_tan_man
      end
    end

    def wsdpn
      @wsdpn ||= @pn.dirname
    end
  end

  class Models_::Remote < Model_

    desc "manage remotes."

    self.after_i = :graph

    Actions = ::Module.new

  end

  class Models_::Graph < Model_

    desc "with the current graph.."

    autoload_actions

    self.after_i = :status

    # desc "there's a lot you can tell about a man from his choice of words"
  end

  class Models_::Node < Model_::Document_Entity

    desc do |y|
      y << "x."
    end

    autoload_actions

    class << self
      def touch
        self::Actors__::Mutate::Touch
      end
    end

    Node_ = self
  end

  class Models_::Association < Model_::Document_Entity

    desc do |y|
      y << "x."
    end

    autoload_actions
  end

  class Models_::Meaning < Model_

    desc "manage meaning."

    self.after_i = :graph

    Stub_ = Stubber_[ self ]

    module Actions
      Add = Stub_[ :Add ]
      Ls  = Stub_[ :Ls ]
      Rm = Stub_[ :Rm ]
    end
  end

  class Models_::Starter < Model_

    autoload_actions
  end

  module Models_::Datastores

    Actions = :_none_

    module Nodes

      Git_Config = Brazen_::Data_Stores_::Git_Config

    end
  end
end
