module Skylab::TanMan
  class API::Actions::Tell < API::Achtung::SubClient
    param :words, accessor: true, list: true, required: true

    include TanMan::Statement::Parser::InstanceMethods
  protected
    def execute
      dot_files.ready? or return
      statement = parse_words(words) or return
      Models::DotFile::Controller.new(request_runtime).invoke(
        pathname: dot_files.selected_pathname,
        statement: statement
      )
    end
  end
end
