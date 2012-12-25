module Skylab::TanMan
  class API::Actions::Graph::Check < API::Action
    extend API::Action::Parameter_Adapter

    param :path, pathname: true, accessor: true
    param :verbose, accessor: true

  protected

    def execute # loooks like [#bs-022] file services below, might get dried
      res = nil
      begin
        if path
          if path.exist?
            if path.directory?
              error "is directory, expecting dotfile: #{ path }"
              res = false
              break
            end
          else
            error "dotfile file not found: #{ path }"
            res = false
            break
          end
        elsif collections.dot_file.ready?
          pn = collections.dot_file.using_pathname
          info "using value set in config: #{ escape_path pn }"
          self.path = pn
        else
          emit :call_to_action, action_class: API::Actions::Graph::Use,
            template: '(then?) use {{action}} to select or create graph' #[#059]
          break
        end
        # as an excercize we build a controller here
        o = TanMan::Models::DotFile::Controller.new self
        b = o.set!  dry_run: false,
                      force: false,
                   pathname: path,
                  statement: false,
                    verbose: (verbose || false)
        b or break
        res = o.check
      end while nil
      res
    end
  end
end
