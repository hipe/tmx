module Skylab::TanMan

  class API::Actions::Graph::Check < API::Action
    extend API::Action::Parameter_Adapter

    param :path, pathname: true, accessor: true

  protected

    def execute
      error 'cover me - finish knob refactor here' ; true and return false
      result = nil
      begin
        if path
          if path.exist?
            if path.directory?
              error "is directory, expecting dotfile: #{ path }"
              result = false
              break
            end
          else
            error "dotfile file not found: #{ path }"
            result = false
            break
          end
        elsif dot_files.ready?
          pn = dot_files.selected_pathname
          info "exists, selected: #{ pn }"
          self.path = pn
        else
          info "no dotfile selected. use use?"
          break
        end
        o = TanMan::Models::DotFile::Controller.new self, path
        result = o.check
      end while nil
      result
    end
  end
end
