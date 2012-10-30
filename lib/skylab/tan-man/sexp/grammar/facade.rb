module Skylab::TanMan
  class Sexp::Grammar::Facade < ::Struct.new(:anchor_module, :grammar_const)
    # experimental wrapper around a grammar with possibly useful svcs added.

    def build_parser_for_rule rule_name
      p = parser_class.new
      p.root = rule_name
      p
    end

    # be extra careful -- this might be asking for trouble
    # #todo - swap this and the build calls
    def parser_for_rule rule_name
      (@parsers_for_rules ||= ::Hash.new do |h, k|
        h[k] = build_parser_for_rule k
      end)[rule_name]
    end

  protected
    def parser_class
      anchor_module.const_get("#{grammar_const}Parser", false)
    end
  end
end
