module Skylab::TanMan

  class API::Actions::Graph::Starter::List < API::Action

    def set! x
      x.nil? or never
    end

  private

    def execute
      scn = services.starters.get_scanner
      while (( starter = scn.gets ))
        emit :payload, starter.label
      end
      nil
    end
  end
end
