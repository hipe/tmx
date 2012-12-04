module Skylab::TanMan

  class API::Actions::Tell < API::Action
    extend API::Action::Parameter_Adapter

    param :force, accessor: true, required: false
    param :words, accessor: true, list: true, required: true

    include TanMan::Statement::Parser::InstanceMethods

  protected

    def execute # public, to be called from self.class
      result = nil
      begin
        dot_files.ready? or break
        statement = parse_words words, force: force
        statement or break
        sc = Models::DotFile::Controller.new self
        result = sc.invoke pathname: dot_files.selected_pathname,
                           statement: statement
      end while nil
      result
    end
  end
end
