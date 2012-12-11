module Skylab::TanMan

  class API::Actions::Graph::Tell < API::Action
    extend API::Action::Parameter_Adapter

    param :force, accessor: true, required: false
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
        res = controllers.dot_file.invoke pathname: selected,
                                         statement: statement,
                                           verbose: false
      end while nil
      res
    end
  end
end
