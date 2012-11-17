module Skylab::TanMan
  class API::Actions::Check < API::Achtung::SubClient
    param :path, pathname: true, accessor: true
  protected
    def execute
      if path
        path.exist? or
         return error("dotfile not found: #{path}")
      else
        dot_files.ready? or return
        info("exists, selected: #{dot_files.selected_pathname}")
        self.path = dot_files.selected_pathname
      end
      TanMan::Models::DotFile::Controller.new(request_runtime, path).check
    end
  end
end
