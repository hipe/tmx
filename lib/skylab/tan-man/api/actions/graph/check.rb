module Skylab::TanMan
  class API::Actions::Graph::Check < API::Action
    extend API::Action::Parameter_Adapter

    param :path, pathname: true, accessor: true
    param :verbose, accessor: true

  private

    def execute # loooks like [#bs-022] file services below, might get dried
      res = nil
      begin
        pathname = path # use the conventional name
        if pathname
          if pathname.exist?
            if pathname.directory?
              # (we do not escape_path below, just use user-provided string)
              error "is directory, expecting dotfile: #{ pathname }"
              res = false
              break
            end
          else
            error "dotfile file not found: #{ pathname }"
            res = false
            break
          end
        elsif collections.dot_file.ready?
          pathname = collections.dot_file.using_pathname
          info "using value set in config: #{ escape_path pathname }"
          self.path = nil # done using it - avoid confusion
        else
          emit :call_to_action, action_class: API::Actions::Graph::Use,
            template: '(then?) use {{action}} to select or create graph' #[#059]
          break
        end
        # we build a controller anew here a) as an excercize and b)
        # so we can have arbitrary whatever paths easily
        # as an excercize we build a controller here
        cnt = TanMan::Models::DotFile::Controller.new self, pathname
        res = cnt.check verbose
      end while nil
      res
    end
  end
end
