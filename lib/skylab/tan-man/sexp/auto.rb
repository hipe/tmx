module Skylab::TanMan
  module Sexp::Auto
    extend Sexp::Inflection::InstanceMethods # symbolize
    CONST_RX = /[^:0-9]+(?=[0-9]+\z)/
    def self.[](syntax_node)
      a = syntax_node.singleton_class.ancestors
      consts = a.first.to_s.split('::')
      nt_const = CONST_RX.match(consts[-1])[0]
      sexp_const = "#{nt_const}Sexp"
      grammar_module = consts[0..-2].reduce(::Object) { |k, c| k.const_get(c) }
      grammar_module.const_defined?(sexp_const) or
        grammar_module.const_set(sexp_const, build(grammar_module, nt_const))
      grammar_module.const_get(sexp_const).build syntax_node
    end
    def self.build grammar_module, nt_const
      a = [] ; n = 0
      loop do
        a.push grammar_module.const_get("#{nt_const}#{n}")
        break unless grammar_module.const_defined?("#{nt_const}#{n += 1}")
      end
      penult = a[-2] or fail('sanity')
      of_interest = penult.instance_methods(false).select { |k| /\d/ !~ k.to_s }
      klass =
      if [:first, :rest] == of_interest
        ::Struct.new(:list).class_eval do
          extend Sexp::Auto::List::ModuleMethods
          self
        end
      else
        ::Struct.new(*of_interest).class_eval do
          extend Sexp::Auto::ModuleMethods
          self
        end
      end
      klass.nt_const = nt_const
      klass.nt_name = symbolize(nt_const)
      klass
    end
  end
  module Sexp::Auto::ModuleMethods
    def build syntax_node
      new(* members.map { |m| syntax_node.send(m).tree } )
    end
    def list? ; false end
    attr_accessor :nt_const, :nt_name
  end
  module Sexp::Auto::List end
  module Sexp::Auto::List::ModuleMethods
    include Sexp::Auto::ModuleMethods
    def build syntax_node
      new( [syntax_node.first.tree] +
            syntax_node.rest.elements.map { |o| o.content.tree } )
    end
    def list? ; true end
  end
end
