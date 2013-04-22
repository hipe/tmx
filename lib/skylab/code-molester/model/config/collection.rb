module Skylab::CodeMolester

  class Model::Config::Collection

    CodeMolester::Services::Face::Model.enhance self do
      services %i|
        has_instance
        set_instance
        config_filename
        config_file_search_num_dirs
        config_file_search_start_pathname
      |
    end

    def init_model_collection plugin_host_proxy
      @plugin_host_proxy = plugin_host_proxy
    end

    def create path, is_dry_run, pth, exists_ev, befor, after, all
      if host.has_instance :config
        skip[ "won't init when a cached config exists." ]
      else
        pn = ::Pathname.new( path ).join( host.config_filename )
        conf = host.set_instance :config do |c|
          c.pathname = pn
        end
        conf.create is_dry_run, pth, exists_ev, befor, after, all
      end
    end

    def find_nearest_config_file_path yes, no
      pn = host.config_file_search_start_pathname
      remaining_tries = host.config_file_search_num_dirs
      fn = host.config_filename
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
      }from #{ pth[ start_pn ] }"
    end

    def if_config yes, no
      if host.has_instance :config
        yes[ ]
      else
        find_nearest_config_file_path -> found_pn do
          host.set_instance :config do |c|
            c.pathname = found_pn
          end
          yes[ ]
        end, -> num_tries, start_pn do
          if ! no then false else
            if 1 == no.arity
              no[
                Events::No[
                  num_tries: num_tries,
                  start_pn: start_pn
                ]
              ]
            else
              no[ ]
            end
          end
        end
      end
    end
  end
end
