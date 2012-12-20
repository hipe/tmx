module Skylab::CodeMolester


  class Config::Sexp < ::Skylab::CodeMolester::Sexp
    extend MetaHell::DelegatesTo # gotta

    S = self

    def build_comment_line line
      line = "# #{line.gsub(/[[:space:]#]+/, ' ').strip}\n" # could be improved
      S[:whitespace_line, '', S[:comment, line]]
    end

  end
                                  # you've got to load them now so they register
  Config::Sexps || nil            # or it has a way of shutting this whole
                                  # thing down

end
