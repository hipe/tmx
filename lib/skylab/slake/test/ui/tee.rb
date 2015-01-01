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
      tee = TestLib_::Tee[].new
      tee[:buffer] = Slake_.lib_.string_IO.new
      if ! silent
        tee[:stream] = stream
      end
      tee
    end

    opt_h_h = {
      err:    -> v { @err = v },
      out:    -> v { @out = v },
      silent: -> v { @silent = v }
    }

    define_method :initialize do |opt_h=nil|
      @silent = nil
      if opt_h
        opt_h.each_pair do |i, x|
          instance_exec x, & opt_h_h.fetch( i )
        end
      end
      @out ||= new_tee[ silent, STDOUT ]
      @err ||= new_tee[ silent, STDERR ]
    end
  end
end
