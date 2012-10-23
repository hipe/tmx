module Skylab::TanMan
  class Sexp::Grammar::Facade < ::Struct.new(:anchor_module, :grammar_const)
    # experimental wrapper around a grammar with possibly useful svcs added.

    def build_parser_for_rule rule_name
      p = parser_class.new
      p.root = rule_name
      p
    end

  protected
    def parser_class
      anchor_module.const_get("#{grammar_const}Parser", false)
    end
  end
end
