module Skylab::CSS_Convert

  class Directive__::Runner

    include Core::SubClient::InstanceMethods

    def invoke directive_sexp # #unwrap [#bs-109] prototypical example

      _const = self._WAS_constantize directive_sexp.node_name

      _klass = Home_::Directives.const_get _const
      _klass.new( request_client, directive_sexp ).invoke
    end
  end
end
