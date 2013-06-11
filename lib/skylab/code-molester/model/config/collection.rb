module Skylab::CodeMolester

  class Model::Config::Collection

    CodeMolester::Services::Face::Model.enhance self do
      service_names %i|
        has_model_instance
        set_new_valid_model_instance
        config_filename
        config_file_search_num_dirs
        config_file_search_start_pathname
      |
    end

    def init_model_collection plugin_host_proxy
      did = false
      @plugin_host_services ||= ( did = true and plugin_host_proxy )
      did or fail "sanity - ivar name collision?"
      nil
    end

    # `create`
    #   + `field_h`  - (exactly):
    #                + `directory`
    #   + `opt_h`    * (please see downstream ~Config_Controller#`create`)
    #   + `event_h`  * (idem)


    def create field_h, opt_h, event_h
      config = nil
      alt = [
        -> {
          if model_svcs.has_model_instance :config
            raise "sanity - won't create when a cached config exists."  # #todo
          end },
        -> {
          directory, = unpack_equal field_h, :directory
          pn = ::Pathname.new( directory ).join( config_svcs.config_filename )
          config = model_svcs.set_new_valid_model_instance :config,
            -> st { st.pathname = pn },
            -> c  { c },
            nil  # sets no error handler #todo
          nil }
      ].reduce( nil ) { |_, f| x = f.[] and break x }
      if alt then alt.call else
        config.create opt_h, event_h
      end
    end

    Services::Basic::Hash::FUN.tap do |fun|
      %i| unpack_equal unpack_superset |.each do |i|
        define_method i, & fun[ i ]
        private i
      end
    end

    # `find_nearest_config_file_path`
    #
    # signature is the "sacred four" [#fa-012]:
    #
    #   + `_fh` - (ignored. future-proofing placeholder for future parameters.)
    #   + `_oh` - (ignored. future-proofing placeholder for future options.)
    #   + `yes` - if found, called with an `x#to_s` => path
    #   + `no`  - else when not found, called with num_tries, start pathname.
    #
    # needs the host services:
    #
    #  + `config_file_search_start_pathname`
    #  + `config_file_search_num_dirs`
    #  + `config_filename`

    def find_nearest_config_file_path _fh, _oh, yes, no
      c = config_svcs ; pn = c.config_file_search_start_pathname
      remaining_tries = c.config_file_search_num_dirs
      fn = c.config_filename
      # --*--
      pn.absolute? or pn = pn.expand_path
      pn.absolute? or fail "sanity"  # it is important
      start_pn = pn
      num_tries = 0
      if remaining_tries > 0
        while true
          num_tries += 1
          try = pn.join fn
          if try.exist? then break found = try end
          if '/' == pn.to_s then break end
          remaining_tries -= 1
          if remaining_tries == 0 then break end
          pn = pn.dirname
        end
      end
      if found
        yes[ found ]
      else
        no[ num_tries, start_pn ]
      end
    end

    module Events
    end

    Events::No = Model::Event.new do |num_tries, start_pn|
      "no config file in the #{ num_tries } dirs starting #{
      }from #{ @pth[ start_pn ] }"
    end

    def if_config yes, no
      if model_svcs.has_model_instance :config then yes[ ]
      else
        find_nearest_config_file_path( nil, nil,
          -> found_pn do
            model_svcs.set_new_valid_model_instance :config, -> c do
              c.pathname = found_pn
            end, yes, no
          end,
          -> num_tries, start_pn do
            no ||= -> { false }
            if 1 != no.arity then no[] else
              no[ Events::No[
                num_tries: num_tries,
                start_pn: start_pn
              ] ]
            end
          end
        )
      end
    end

  private

    def plugin_host_services
      @plugin_host_services
    end

    alias_method :model_svcs, :plugin_host_services

    alias_method :config_svcs, :plugin_host_services

  end
end
