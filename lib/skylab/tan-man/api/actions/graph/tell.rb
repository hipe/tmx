module Skylab::TanMan

  class API::Actions::Graph::Tell < API::Action
    extend API::Action::Parameter_Adapter

    param :dry_run, accessor: true, default: false
    param :force, accessor: true, required: false
    param :verbose, accessor: true, default: false
    param :words, accessor: true, list: true, required: true

    include TanMan::Statement::Parser::InstanceMethods

  protected

    def execute
      res = nil
      begin
        controller = collections.dot_file.selected or break
        statement = parse_words words, force: force
        statement or break
        selected = collections.dot_file.selected_pathname
        res = controller.invoke            dry_run: dry_run,
                                         statement: statement,
                                           verbose: verbose
      end while nil
      res
    end
  end
end
