module Skylab::TanMan
  class Sexp::Grammar::Facade < ::Struct.new :anchor_module, :grammar_const
    # experimental wrapper around a grammar with possibly useful svcs added.

    def build_parser_for_rule rule_name
      p = parser_class.new
      p.root = rule_name.intern
      p
    end

    def has_rule? name # name e.g. "stmt_list", :stmt_list
      self.module.instance_methods.include? "_nt_#{ name }".intern
    end

    def module
      anchor_module.const_get grammar_const, false
    end

    # be extra careful -- this might be asking for trouble
    # #watch'ing #danger [#054] - swap this and the build calls?
    def parser_for_rule rule_name
      (@parsers_for_rules ||= ::Hash.new do |h, k|
        h[k] = build_parser_for_rule k
      end)[rule_name]
    end

    def parser_class
      anchor_module.const_get "#{ grammar_const }Parser", false
    end

  protected

    # none

  end
end
