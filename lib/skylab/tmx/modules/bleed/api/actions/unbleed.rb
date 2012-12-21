module Skylab::Tmx::Modules::Bleed::Api
  class Actions::Unbleed < BashAction
    def invoke
      parts = env_path.split(':')
      path = parts.first
      if /\bbleed/ !~ path
        info "nerp: expecting to see the string \"bleed\" here: \"#{path}\""
      else
        info "shifting this element off the head of the PATH: \"#{path}\""
        set_env_path parts[1..-1].join(':')
      end
    end
  end
end
