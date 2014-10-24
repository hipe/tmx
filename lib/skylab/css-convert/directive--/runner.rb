module Skylab::CSS_Convert

  class Directive__::Runner

    include Core::SubClient::InstanceMethods

    def invoke directive_sexp # #unwrap [#bs-109] prototypical example

      CSSC_::Lib_::Old_name_lib[].constantize directive_sexp.node_name

      _klass = CSSC_::Directives.const_get _const
      _klass.new( request_client, directive_sexp ).invoke
    end
  end
end
