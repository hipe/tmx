module Skylab::TanMan

  class Core::Event < PubSub::Event
    # this is all very experimental and subject to change!
  end

  Core::Event::GRAPH = Bleeding::EVENT_GRAPH.merge(
    info: :all, out: :all, no_config_dir: :error, skip: :info
  )

end
