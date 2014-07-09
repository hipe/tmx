module Skylab::TMX

  module Modules::Bleed::API

    module Actions
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
