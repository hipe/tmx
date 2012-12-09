module Skylab::TanMan

  class Models::Config::Resource < CodeMolester::Config::File

                                  # (we make the below method public)
    def clear                     # we've gotta take responsibility for this:
      @remotes and @remotes.clear # to be absolutely insane, we want to see if
      super                       # we have have these "resources" be long-
    end                           # running.  We will taste the pain.

    def remotes
      @remotes ||= begin
        TanMan::Models::Remote::Collection.new self
      end
    end

  protected

    def initialize param_h
      @remotes = nil
      super param_h
    end
  end



  class Models::Config::Resource::Global < Models::Config::Resource
    def clear
      pn = @pathname              # obnoxiously we want to keep the same
      super                       # pathname for life (for now!) even when
      @pathname = pn              # our api asks us to `clear`
      nil
    end
  end



  class Models::Config::Resource::Local < Models::Config::Resource

                                  # nothing special for now!

  end
end
