module Skylab::CssConvert
  class Directive::Runner
    include ::Skylab::Autoloader::Inflection::InstanceMethods
    include My::Headless::SubClient::InstanceMethods
    def invoke directive_sexp # @prototypical:"example of unwrapping"
      _const = constantize(directive_sexp.node_name)
      _klass = CssConvert::Directives.const_get(_const)
      _klass.new(request_runtime, directive_sexp).invoke
    end
  end
end
