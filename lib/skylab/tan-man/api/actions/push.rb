module Skylab::TanMan
  class API::Actions::Push < API::Action
    attribute :dry_run, boolean: true, default: false
    attribute :file_path, required: true, pathname: true
    attribute :remote_name, required: true
    emits :all, negative: :all, info: :all,
      file_not_found: :negative,
      remote_not_found: :negative

    def execute
      config.ready? or return
      @remote = config.remotes.get(remote_name, self) or return
      unless file_path.exist?
        emit(:file_not_found,
          message: "file to push not found: #{file_path.pretty.inspect}")
        return false
      end
      cmd = "scp #{file_path} #{remote_path}"
      emit(:info, cmd)
      unless dry_run?
        exec cmd
      end
      true
    end

    def remote_path
      File.join @remote.url, file_path.basename
    end
  end
end

