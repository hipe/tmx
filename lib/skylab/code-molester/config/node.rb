module Skylab::CodeMolester
  require Config::DIR.join('../auto-sexp')
  require ::File.expand_path('../sexp-classes', __FILE__)

  class Config::Node < ::Treetop::Runtime::SyntaxNode
    extend AutoSexp
    sexp_factory_class Config::Sexp
  end
end

