module Skylab::TanMan

  class Core::Event < PubSub::Event
    # this is all very experimental and subject to change!

    def message= msg
      update_attributes! message: msg
    end
  end

  Core::Event::GRAPH = Bleeding::EVENT_GRAPH.merge(
    info: :all, out: :all, no_config_dir: :error, skip: :info
  )
end
