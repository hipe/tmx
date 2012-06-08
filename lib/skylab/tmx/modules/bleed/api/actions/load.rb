module Skylab::Tmx::Modules::Bleed::Api
  class Actions::Load < Action
    emits bash_stdout: :all
    def error msg
      emit(:bash_stdout, bash: "echo #{"error: #{msg}. hack failed.".inspect}")
      false
    end
    def info msg
      emit(:bash_stdout, bash: "echo #{msg.inspect}")
      nil
    end
    def invoke
      (config_read and dir = config_get_path) or return
      dir = File.expand_path("#{dir}/bin", config.path) # we want no tilde, etc here
      File.directory?(dir) or return error("not a directory, won't add to PATH: #{dir}")
      env_path = ENV['PATH']
      parts = env_path.split(':')
      case parts.index(dir)
      when nil
        info "prepending bin folder to the beginning of the PATH."
        set_env_path ([dir] + parts).join(':')
      when 0
        info "already at front of path: \"#{dir}\""
      else
        info "rewriting path to have bin folder at the beginning"
        set_env_path ([dir] + parts.reject{ |x| x == path }).join(':')
      end
    end
    def set_env_path path
      emit(:bash_stdout, bash: "export PATH=\"#{path}\"")
    end
  end
end

