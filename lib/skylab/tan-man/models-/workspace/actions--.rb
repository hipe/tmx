module Skylab::TanMan

  class Models_::Workspace  # re-opening

    Actions__ = ::Module.new

    class Actions__::Status < Brazen_::Models_::Workspace::Actions::Status

      extend Action_::MM

      @is_promoted = true

      @after_name_symbol = :init

      desc "show the status of the config director{y|ies} active at the path"

    end

    class Actions__::Init < Brazen_::Models_::Workspace::Actions::Init

      extend Action_::MM

      @is_promoted = true

      desc do |y|
        _ = @kernel.silo( :workspace ).model_class.default_config_filename
        y << "create the #{ val _ } directory"
      end
    end

    class Actions__::Ping < Action_

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
  end
end
