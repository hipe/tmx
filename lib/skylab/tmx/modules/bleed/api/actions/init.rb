module Skylab

  class TMX::Modules::Bleed::API::Actions::Init <
    TMX::Modules::Bleed::API::Action

    listeners_digraph info: :all, error: :all, head: :all, tail: :all

    def invoke

      if config.exist?
        info "exists, won't overwrite - #{ escape_path config.path }"
        nil
      else

        config['bleed'] ||= { } # create the section called [bleed]

        config['bleed']['path'] =  # (below was [#sl-122])
          contract_tilde ::Skylab.dir_pathname.join( '../..' ).to_s

        config_write
      end
    end
  end
end
