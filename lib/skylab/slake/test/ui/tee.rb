module Skylab::Slake::TestSupport

  class UI::Tee                   # experimental custom runtime spy etc.
                                  # (not really a proper tee - misnomer?)

    attr_accessor :err, :out, :silent

    [:out, :err].each do |stream|
      define_method "#{ stream }_string" do
        send( stream )[:buffer].string
      end
    end

    new_tee = -> silent, stream do
      tee = Headless::IO::Interceptors::Tee.new
      tee[:buffer] = Slake::Lib_::StringIO[].new
      if ! silent
        tee[:stream] = stream
      end
      tee
    end

    opt_h_h = {
      err:    -> v { @err = v },
      out:    -> v { @out = v },
      silent: -> v { @slient = v }
    }

    define_method :initialize do |opt_h=nil|
      @silent = nil
      opt_h.each { |k, v| instance_exec( v, & opt_h_h.fetch( k ) ) } if opt_h
      @out ||= new_tee[ silent, STDOUT ]
      @err ||= new_tee[ silent, STDERR ]
    end
  end
end
