module Skylab::CSS_Convert

  class Directive__::Runner

    def initialize _

      @_client = _
    end

    def invoke directive_sexp # #unwrap [#bs-109] prototypical example

      _const = Common_::Name.via_variegated_symbol(
        directive_sexp.node_name
      ).as_const

      _cls = Home_::Directives__.const_get _const

      _stmt = _cls.new @_client, directive_sexp

      _stmt.execute
    end
  end
end
