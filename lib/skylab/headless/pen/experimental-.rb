module Skylab::Headless

  module Pen::Experimental_

    # this whole file has an ugly name so you don't confuse it for something
    # stable.

  end

  class Pen::Experimental_::Plugin_Services_

    # experimental crazy fun hack - the pen can be conceptualized as a plugin
    # host that has services: action nodes that want to render themselves in
    # a particular modality context might load themselves as a plugin,
    # unwittingly using the *PEN* as the plugin host!
    #
    # we want to be stateless because pens are often stateless singleton-like
    # colletions of functions per modality (and/or per application), and
    # managing a list of listeners to eventpoints for a pen is silly and
    # meaningless. hence we hack a relevant subset of the interface for a
    # host services that may one day get merged in. :[#hl-071]
    #

    def initialize pen
      @pen = -> { pen }
      @svc_h = { }
    end

    def build_host_proxy _client  # it's just a pen. meh.
      nil
    end

    def call_host_service _plugin_story, svc_i
      @svc_h.fetch svc_i do |k|
        @svc_h[ k ] = @pen[].method svc_i
      end
    end
  end
end
