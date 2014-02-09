module Skylab::CodeMolester


  class Config::Sexp < CodeMolester::Sexp

    Lib_::Delegating[ self, :employ_the_DSL_method_called_delegates_to ]

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
