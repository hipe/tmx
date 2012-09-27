module Skylab::Tmx::Modules::Bleed::Api
  class Actions::Init < Action
    def invoke
      if config.exist?
        emit :info, "exists, won't overwrite: #{config.pretty}"
        return nil
      end
      path = contract_tilde(::Skylab::ROOT_PATHNAME.to_s)
      config['bleed'] ||= {} # create the section called [bleed]
      config['bleed']['path'] = path
      config_write
    end
  end
end

