module Skylab::CssConvert
  class Directive::Runner
    include Core::SubClient::InstanceMethods
    def invoke directive_sexp # #unwrap [#bs-109] prototypical example
      _const = Inflection::FUN.constantize[ directive_sexp.node_name ]
      _klass = CssConvert::Directives.const_get _const
      _klass.new( request_runtime, directive_sexp ).invoke
    end
  end
end
