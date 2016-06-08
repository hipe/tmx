module Skylab::TanMan

  class Models_::Workspace  # re-opening

    Actions__ = ::Module.new

    class Actions__::Status < Brazen_::Models_::Workspace::Actions::Status

      extend Action_::MM

      @is_promoted = true

      @after_name_symbol = :init

      @description_proc = -> y do
        y << "show the status of the config director{y|ies} active at the path"
      end

    end

    class Actions__::Init < Brazen_::Models_::Workspace::Actions::Init

      extend Action_::MM

      @is_promoted = true

      @description_proc = -> y do
        _ = @kernel.silo( :workspace ).silo_module.default_config_filename
        y << "create the #{ val _ } directory"
      end
    end

    class Actions__::Ping < Action_

      Entity_.call self,

          :promote_action,

          :branch_description, -> y do
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

        Common_::Event.inline_neutral_with(
          :ping
        ) do | y, o |
          y << "hello from #{ an }."
        end
      end
    end
  end
end
