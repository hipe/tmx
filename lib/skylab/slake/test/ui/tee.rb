module Skylab::Slake::TestSupport
  class UI::Tee                   # experimental custom runtime spy etc.
                                  # (not really a proper tee - misnomer?)

    attr_accessor :err, :out, :silent

    [:out, :err].each do |stream|
      define_method "#{ stream }_string" do
        send( stream )[:buffer].string
      end
    end

    tee = -> silent, stream do # #todo after [#mh-017] clean this up, use box-like add
      if silent
        MetaHell::Proxy::Tee.new buffer: ::StringIO.new
      else
        MetaHell::Proxy::Tee.new stream: stream, buffer: ::StringIO.new
      end
    end

    opt_h_h = {
      err:    -> v { @err = v },
      out:    -> v { @out = v },
      silent: -> v { @slient = v }
    }

    define_method :initialize do |opt_h=nil|
      opt_h.each { |k, v| instance_exec( v, & opt_h_h.fetch( k ) ) } if opt_h
      @out ||= tee[ silent, $stdout ]
      @err ||= tee[ silent, $stderr ]
    end
  end
end
