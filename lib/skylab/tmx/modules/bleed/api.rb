require 'skylab/headless/core'  # meh

module Skylab

  module TMX::Modules::Bleed::API
  end

  module TMX::Modules::Bleed::API
    module Actions
      MetaHell::Boxxy[ self ]
    end
  end

  class TMX::Modules::Bleed::API::Client

    def invoke action_ref, *args, &events
      events or raise ::ArgumentError, "for now, block is required."
      kls = TMX::Modules::Bleed::API::Actions.const_fetch action_ref
      act = kls.new( & events )
      act.invoke( *args )
    end
  end
end
