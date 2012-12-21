module Skylab::CodeMolester


  class Config::Node < ::Treetop::Runtime::SyntaxNode
    extend CodeMolester::AutoSexp
    sexp_factory_class Config::Sexp
  end

end
