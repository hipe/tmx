module Skylab::TMX::Modules::Bleed::API
  class Actions::Load < BashAction
    def invoke
      (config_read and dir = config_get_path) or return
      dir = File.expand_path("#{dir}/bin", config.path) # we want no tilde, etc here
      File.directory?(dir) or return error("not a directory, won't add to PATH: #{dir}")
      parts = env_path.split(':')
      case parts.index(dir)
      when nil
        info "prepending bin folder to the beginning of the PATH."
        set_env_path(([dir] + parts).join(':'))
      when 0
        info "already at front of path: \"#{dir}\""
      else
        info "rewriting path to have bin folder at the beginning"
        set_env_path(([dir] + parts.reject{ |x| x == path }).join(':'))
      end
    end
  end
end

