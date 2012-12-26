module Skylab::TanMan
  class API::Actions::Graph::Tell < API::Action
    extend API::Action::Parameter_Adapter

    param :dry_run, accessor: true, default: false
    param :force, accessor: true, default: false
    param :rebuild_tell_grammar, accessor: true, default: false
    param :verbose, accessor: true, default: false
    param :words, accessor: true, list: true, required: true

    include TanMan::Statement::Parser::InstanceMethods

  protected

    def execute
      res = nil
      begin
        controller = collections.dot_file.currently_using or break
        statement = parse_words( words ) or break
        res = controller.tell statement, dry_run, force, verbose
      end while nil
      res
    end
  end
end
