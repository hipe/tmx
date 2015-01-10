module Skylab::TanMan

  class Models::Config::Resource <
    Headless::Services::CodeMolester::Config::File::Model

                                  # we've gotta take responsibility for this:
                                  # to be absolutely insane, we want to see if
                                  # we can have these "resources" be long-
                                  # running.  We will taste the pain.
    def clear_config_resource
      @remotes and @remotes.clear_remote_collection
      clear                       # (call up to cm::config::file)
      nil
    end

    attr_reader :normalized_resource_name

    def remotes
      @remotes ||= begin
        TanMan::Models::Remote::Collection.new self
      end
    end

    def into_entity_merge_properties_emitting_to_p section_s, x_a, p
      sections[ section_s ] ||= { }
      o = sections[ section_s ]
      while x_a.length.nonzero?
        v_x = x_a.fetch( 1 ) ; k_x = x_a.shift ; x_a.shift
        v_s = v_x.to_s ; k_s = k_x.to_s
        if o.key? k_s
          v_s_ = o[ k_s ]
          if v_s == v_s_
            p[ :same, k_x, v_x ]
          else
            p[ :change, k_x, v_s_, v_x ]
            o[ k_s ] = v_s
          end
        else
          p[ :add, k_x, v_x ]
          o[ k_s ] = v_x
        end
      end
      true
    end

    Remove_hooks__ = -> do
      p = -> do
        Remove_Hooks__ = Headless::Event::Hooks.new :not_found, :success
        p = -> { Remove_Hooks__ }
        Remove_Not_Found__ = self._TODO_data_event.new do |section_name_s|
          "no such section [#{ section_name_s }]"
        end
        Remove_Success__ = self._TODO_data_event.new do |section_name_s|
          "removed section [#{ section_name_s }]"
        end
        Remove_Hooks__
      end
      -> { p.call }
    end.call

    def remove_entity_by_section_name name_s, & event_p
      event_p[ on = Remove_hooks__[].new ]
      if (( section = sections[ name_s ] ))
        sections.remove( section ) or never  # raises on failure, sexp on OK
        on.success_p[ Remove_Success__[ name_s ] ]
      else
        on.not_found_p[ Remove_Not_Found__[ name_s ] ]
      end
    end

  private

    def initialize param_h
      @normalized_resource_name = param_h.delete :normalized_resource_name
      @remotes = nil
      super param_h
    end
  end



  class Models::Config::Resource::Global < Models::Config::Resource
    def clear_config_resource
      pn = @pathname              # obnoxiously we want to keep the same
      super                       # pathname for life (for now!) even when our
      @pathname = pn              # api calls on us to `clear_config_resource`
      nil
    end
  end



  class Models::Config::Resource::Local < Models::Config::Resource

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

    def anchor_pathname                        # if the config file is
      pathname.join '../..'                    # .tanman/config, the anchor
    end                                        # path is the path that has
  end                                          # the .tanman dir in it.
end
