module Skylab::CodeMolester

  module Models

    module Config  # ~ stowaway

      Event_ = LIB_.old_event_lib

      class Collection

    LIB_.model_enhance self, -> do

      services_used( * %i|
        has_model_instance
        set_new_valid_model_instance
        config_filename
        config_search_num_dirs
        config_get_search_start_pathname
      | )

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
          if has_model_instance :config
            raise "sanity - won't create when a cached config exists."  # #todo
          end },
        -> {
          directory, = unpack_equal field_h, :directory
          pn = ::Pathname.new( directory ).join( config_filename )
          config = set_new_valid_model_instance :config,
            -> st { st.pathname = pn },
            -> c  { c },
            nil  # sets no error handler #todo
          nil }
      ].reduce( nil ) { |_, f| x = f.[] and break x }
      if alt then alt.call else
        config.create opt_h, event_h
      end
    end

  private

    LIB_.hash_lib.pairs_at :unpack_equal, :unpack_superset,
      & method( :define_method )

  public

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
    #  + `config_get_search_start_pathname`
    #  + `config_search_num_dirs`
    #  + `config_filename`

    def find_nearest_config_file_path _fh, _oh, yes, no
      pn = config_get_search_start_pathname
      remaining_tries = config_search_num_dirs
      fn = config_filename
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

    No__ = Event_.new do |num_tries, start_pn|
      "no config file in the #{ num_tries } dirs starting #{
      }from #{ @pth[ start_pn ] }"
    end

    def if_config yes_p, no_p  # #todo this is so much worse than [br]
      if has_model_instance :config
        yes_p
      else
        find_nearest_config_file_path( nil, nil,
          -> found_pn do
            set_new_valid_model_instance :config, -> c do
              c.pathname = found_pn
            end, yes_p, no_p
          end,
          -> num_tries, start_pn do
            no_p ||= -> { false }
            if 1 == no_p.arity
              no_p[ No__[
                :num_tries, num_tries,
                :start_pn, start_pn
              ] ]
            else
              no_p[]
            end
          end
        )
      end
    end
      end

      Config_ = self
    end
  end
end
