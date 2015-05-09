module Skylab::Treemap

  module Adapter::CLI
  end

  module Adapter::CLI::Action
  end

  module Adapter::CLI::Action::InstanceMethods

    # remember the (probably produced) adapter cli action class descends
    # form our native cli action class.

    def initialize mc  # (we hack-circumvent noisy cluttered wiring for now)

      init_treemap_sub_client mc  # (be careful!)
      esg = self.class.event_stream_graph  # ([#bm-001] when is this justified?)

      Treemap::CLI::Event::CANON_STREAMS.each do |stream_symbol|
        if esg.has? stream_symbol
          on stream_symbol, mc.handle( stream_symbol )
        end
      end

      if_unhandled_streams { |msg| raise ::ArgumentError, msg }
    end
  end
end
