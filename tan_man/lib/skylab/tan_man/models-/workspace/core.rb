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
  end
end
# #tombstone-A: "ping" used to live here
