module Skylab::TanMan
  module Models::DotFile::Sexp::InstanceMethods::StmtList
    def destroy_child! child_stmt
      stmt_list_removed = _remove! child_stmt
      stmt_list_removed
    end
  end
end
