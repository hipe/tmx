module Skylab::Headless

  module Pen::Experimental_

    # this whole file has an ugly name so you don't confuse it for something
    # stable.

  end

  class Pen::Experimental_::Plugin_Host_MetaServices_

    # experimental crazy fun hack - the pen can be conceptualized as a plugin
    # host that has services: action nodes that want to render themselves in
    # a particular modality context might load themselves as a plugin,
    # unwittingly using the *PEN* as the plugin host!
    #
    # we want to be stateless because pens are often stateless singleton-like
    # colletions of functions per modality (and/or per application), and
    # managing a list of listeners to eventpoints for a pen is silly and
    # meaningless. hence we hack a relevant subset of the interface for a
    # host services that may one day get merged in. :[#071]
    #

    def initialize pen
      @pen = -> { pen }
      @svc_h = { }
    end

    def proc_for_has_service
      MONADIC_TRUTH_
    end

    def call_service i, _=nil, _=nil
      @svc_h.fetch i do |k|
        @svc_h[ k ] = @pen[].method i
      end
    end
  end
end
