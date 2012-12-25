module Skylab::TanMan
  class API::Actions::Graph::Push < API::Action
    extend API::Action::Attribute_Adapter

    attribute :dry_run, boolean: true, default: false
    attribute :file_path, required: true, pathname: true
    attribute :remote_name, required: true

    emits :all, negative: :all, info: :all,
      file_not_found: :negative,
      remote_not_found: :negative

  protected

    def execute
      error 'cover me' ; true and return false
      result = nil
      begin
        controllers.config.ready? or break
        r = controllers.config.remotes.get remote_name, self
        r or break
        self.remote = r
        if ! file_path.exist?
          emit :file_not_found,
            message: "file to push not found: #{ escape_path file_path }"
          result = false
          break
        end
        cmd = "scp #{ file_pathi } #{ remote_path }"
        emit :info, cmd
        if ! dry_run?
          result = exec cmd # WAT
        end
      end
      result
    end

    attr_accessor :remote

    def remote_path
      ::File.join remote.url, file_path.basename
    end
  end
end
