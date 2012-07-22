module Skylab::Tmx::Modules::Bleed::Api
  class BashAction < Action
    emits :bash
    def env_path
      ENV['PATH']
    end
    def error msg
      emit(:bash, bash: "echo #{"error: #{msg}. hack failed.".inspect}")
      false
    end
    def info msg
      emit(:bash, bash: "echo #{msg.inspect}")
      nil
    end
    def set_env_path path
      emit(:bash, bash: "export PATH=\"#{path}\"")
    end
  end
end
