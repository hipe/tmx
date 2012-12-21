module Skylab::TanMan

  class API::Actions::Graph::Tell < API::Action
    extend API::Action::Parameter_Adapter

    param :dry_run, accessor: true, default: false
    param :force, accessor: true, required: false
    param :verbose, accessor: true, default: false
    param :words, accessor: true, list: true, required: true

    include TanMan::Statement::Parser::InstanceMethods

  protected

    def execute # public, to be called from self.class
      res = nil
      begin
        collections.dot_file.ready? or break
        statement = parse_words words, force: force
        statement or break
        selected = collections.dot_file.selected_pathname
        res = controllers.dot_file.invoke  dry_run: dry_run,
                                          pathname: selected,
                                         statement: statement,
                                           verbose: verbose
      end while nil
      res
    end
  end
end
