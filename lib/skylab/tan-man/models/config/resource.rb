module Skylab::TanMan

  class Models::Config::Resource < CodeMolester::Config::File

                                  # (we make the below method public)
    def clear                     # we've gotta take responsibility for this:
      @remotes and @remotes.clear # to be absolutely insane, we want to see if
      super                       # we have have these "resources" be long-
    end                           # running.  We will taste the pain.

    attr_reader :normalized_resource_name

    def remotes
      @remotes ||= begin
        TanMan::Models::Remote::Collection.new self
      end
    end

  protected

    def initialize param_h
      @normalized_resource_name = param_h.delete :normalized_resource_name
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

    def absolutize_path path
      fail 'do me'

    end

    def derelativize_path relpath              # expand paths that were once
      anchor_pathname.join relpath             # short and pretty.
    end

    def relativize_pathname pathname           # make `pathname` relative to
      if ! pathname.absolute?                  # e.g the directory that has the
        pathname = pathname.expand_path        # .tanman config dir in it.
      end                                      # this is what *feels* right.
      pathname.relative_path_from anchor_pathname # this makes them prettier
    end                                        # in the config file, and more
                                               # portable in its way,
                                               # less portable in another way

  protected

    def anchor_pathname                        # if the config file is
      pathname.join '../..'                    # .tanman/config, the anchor
    end                                        # path is the path that has
  end                                          # the .tanman dir in it.
end
