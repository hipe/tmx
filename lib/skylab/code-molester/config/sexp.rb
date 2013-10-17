module Skylab::CodeMolester


  class Config::Sexp < CodeMolester::Sexp

    extend MetaHell::DelegatesTo # gotta

    Sexp::Registrar[ self ]

    S = self

    def build_comment_line line
      line = "# #{line.gsub(/[[:space:]#]+/, ' ').strip}\n" # could be improved
      S[:whitespace_line, '', S[:comment, line]]
    end
  end

  Config::Sexps.class  # you've got to load them now so they
    # register or it has a way of shutting this whole thing down

end
