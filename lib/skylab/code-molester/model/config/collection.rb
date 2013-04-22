module Skylab::Cull

  class Models::Config::Collection

    module Events
    end

    def init path, is_dry_run, pth, exists_ev, before, after, info, all
      if @model.cached? :config
        skip[ "won't init when a cached config exists." ]
      else
        pn = ::Pathname.new( path ).join( Models::Config.filename )
        conf = @model.cache! :config do |c|
          c.pathname = pn
        end
        conf.init is_dry_run, pth, exists_ev, before, after, info, all
      end
    end

    def find_nearest_config_file_path yes, no
      pn = @model.config_file_search_start_pathname[]
      remaining_tries = @model.config_file_search_num_dirs
      fn = Models::Config.filename
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

    Events::No = Models::Event.new do |num_tries, start_pn|
      "no config file in the #{ num_tries } dirs starting #{
      }from #{ pth[ start_pn ] }"
    end

    def if_config yes, no
      if @model.cached? :config
        yes[ ]
      else
        find_nearest_config_file_path -> found_pn do
          @model.cache! :config do |c|
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

    def initialize client
      @model = client
    end
  end
end
