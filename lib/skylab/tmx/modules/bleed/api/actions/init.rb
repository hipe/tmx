module Skylab

  class TMX::Modules::Bleed::API::Actions::Init <
    TMX::Modules::Bleed::API::Action

    emits info: :all, error: :all, head: :all, tail: :all

    def invoke

      if config.exist?
        info "exists, won't overwrite - #{ escape_path config.path }"
        nil
      else

        config['bleed'] ||= { } # create the section called [bleed]

        config['bleed']['path'] = contract_tilde ::Skylab::ROOT_PATHNAME.to_s

        config_write
      end
    end
  end
end
