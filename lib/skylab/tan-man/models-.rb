module Skylab::TanMan

  DESC_METHOD_ = -> s = nil, & p do
    if s && ! p
      self.description_block = -> y { y << s }
    elsif p
      self.description_block = p
    end ; nil
  end

  Entity_ = Brazen_::Model_::Entity[ -> do

  end ]

  Actor_ = -> cls, * a do
    Callback_::Actor.via_client_and_iambic cls, a
    Event_[].sender cls ; nil
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
            Callback_.scan.nonsparse_array [ self ]
          end

          alias_method :orig_gulas, :get_unbound_lower_action_scan

          def get_unbound_lower_action_scan
            self.const_get :Actions, false
            get_unbound_lower_action_scan
          end
        end
      end

      def entity_module
        Entity_
      end
    end

    attr_reader :error_count
  end

  Stubber_ = -> model do
    -> i do
      Stub__.new i do |x|
        _action_cls = model::Actions__.const_get i, false
        _action_cls.new x
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

  class Action_ < Brazen_::Model_::Action

    extend module MM

      define_method :desc, DESC_METHOD_

      self
    end

    include module IM

    private

      def bound_call_for_ping
        _ev = build_OK_event_with :ping_from_action, :name_i,
           name.as_lowercase_with_underscores_symbol
        x = send_event _ev
        Brazen_.bound_call -> { x }, :call
      end

      def when_unparsed_iambic_exists
        msg = say_strange_iambic
        _ev = build_not_OK_event_with :unrecognized_property,
            :current_iambic_token, current_iambic_token do |y, o|
          y << msg
        end
        send_event _ev
      end

      def send_event ev
        ev_ = ev.to_event
        if ev_.has_tag :ok and ! ev_.ok
          @error_count += 1
        end
        event_receiver.receive_event ev
      end

    public

      def receive_event ev
        m_i = :"receive_#{ ev.terminal_channel_i }_event"
        if respond_to? m_i
          send m_i, ev
        else
          event_receiver.receive_event ev
        end
      end

    private

      def client_adapter
        @event_receiver
      end

      self
    end
  end

  class Kernel_ < Brazen_::Kernel_  # :[#083].

    def retrieve_property_value i
      properties.retrieve_value i
    end
  private
    def properties
      @properties ||= @module::Kernel__::Properties.new
    end
  end

  Autoloader_[ ( Models_ = ::Module.new ), :boxxy ]

  class Models_::Workspace < Brazen_::Models_::Workspace

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
        an = client_adapter.app_name.gsub Callback_::DASH_, Brazen_::SPACE_
        ev = build_neutral_event_with :ping do |y, o|
          y << "hello from #{ an }."
        end
        send_event ev
        :hello_from_tan_man
      end
    end
  end

  class Models_::Remote < Model_

    desc "manage remotes."

    self.after_i = :graph

    Actions = ::Module.new

  end

  class Models_::Graph < Model_

    desc "with the current graph.."

    self.after_i = :status

    Actions = ::Module.new

    class Actions::Tell < Action_

    desc "there's a lot you can tell about a man from his choice of words"

    end
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
end
