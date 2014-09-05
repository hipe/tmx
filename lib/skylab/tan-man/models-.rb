module Skylab::TanMan

  Entity_ = Brazen_::Model_::Entity[ -> do
    cls = ::Class.new
    self::Property = cls
    set_property_class cls
  end ]

  DESC_METHOD_ = -> s = nil, & p do
    if s && ! p
      self.description_block = -> y { y << s }
    elsif p
      self.description_block = p
    end ; nil
  end

  class Model_ < Brazen_::Model_

    define_singleton_method :desc, DESC_METHOD_

  end

  class Action_ < Brazen_::Model_::Action

    extend module MM

      define_method :desc, DESC_METHOD_

      self
    end

    include module IM

    private

      def send_payload_event ev
        @client_adapter.receive_payload_event ev
      end

      def send_info_event ev
        @client_adapter.receive_info_event ev
      end

      self
    end
  end

  class Kernel_ < Brazen_::Kernel_
    def retrieve_property_value i
      return 'term-merm'
      # properties.retrieve_value i
    end
  private
    def properties
      @properties ||= self.class::Properties__.new
    end
  end

  Models_ = ::Module.new

  class Models_::Workspace < Brazen_::Models_::Workspace

    Actions = ::Module.new

    class Actions::Status < Brazen_::Models_::Workspace::Actions::Status

      extend Action_::MM

      self.is_promoted = true

    desc "show the status of the config director{y|ies} active at the path."

      def execute
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

      def execute
        an = @client_adapter.app_name.gsub Callback_::DASH_, Brazen_::SPACE_
        ev = build_event_with :ping do |y, o|
          y << "hello from #{ an }."
        end
        send_info_event ev
        :hello_from_tan_man
      end
    end
  end

  class Models_::Remote < Model_

    desc "manage remotes."

    Actions = ::Module.new

  end

  class Models_::Graph < Model_

    desc "with the current graph.."

    Actions = ::Module.new

    class Actions::Tell < Action_

    desc "there's a lot you can tell about a man from his choice of words"

    end
  end
end
