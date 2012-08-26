module Skylab::TanMan
  module Sexp::Auto end
  module Sexp::Auto::Builder end
  module Sexp::Auto::Builder::Methods
    include Sexp::Inflection::InstanceMethods # symbolize
    CONST_RX = /[^0-9]+(?=[0-9]+\z)/
    def [](syntax_node)
      a = syntax_node.singleton_class.ancestors
      consts = a.first.to_s.split('::')
      nt_const = CONST_RX.match(consts[-1])[0]
      sexp_const = "#{nt_const}Sexp"
      grammar_module = consts[0..-2].reduce(::Object) { |k, c| k.const_get(c) }
      grammar_module.const_defined?(sexp_const) or
        grammar_module.const_set(sexp_const, build(grammar_module, nt_const))
      grammar_module.const_get(sexp_const).build syntax_node
    end
    def build grammar_module, nt_const
      a = [] ; n = 0
      loop do
        a.push grammar_module.const_get("#{nt_const}#{n}")
        break unless grammar_module.const_defined?("#{nt_const}#{n += 1}")
      end
      penult = a[-2] or fail('sanity')
        # this second to last module has all the NT names we put in the grammar
      of_interest = instance_methods_of_interest(penult)
      me = self
      klass =
      if [:first, :rest] == of_interest
        ::Struct.new(:list).class_eval do
          extend Sexp::Auto::List::ModuleMethods
          me.instance_methods_module and include(me.instance_methods_module)
          self
        end
      elsif ! of_interest.empty?
        ::Struct.new(*of_interest).class_eval do
          extend me.module_methods_module
          me.instance_methods_module and include(me.instance_methods_module)
          self
        end
      else
        fail("sorry, found no NT's of interest in #{nt_const}")
      end
      klass.nt_const = nt_const
      klass.nt_name = symbolize(nt_const)
      klass
    end
    def instance_methods_module ; nil end
    def instance_methods_of_interest mod
      mod.instance_methods.select { |k| /\d/ !~ k.to_s }
    end
    def module_methods_module ; Sexp::Auto::ModuleMethods end
  end
  Sexp::Auto.extend Sexp::Auto::Builder::Methods
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
  # --*--
  module Sexp::Auto::Lossless
    extend Sexp::Auto::Builder::Methods
    def self.instance_methods_of_interest(mod) ; mod.instance_methods end
    def self.instance_methods_module ; Sexp::Auto::Lossless::InstanceMethods end
    def self.module_methods_module   ; Sexp::Auto::Lossless::ModuleMethods end
  end
  module Sexp::Auto::Lossless::ModuleMethods
    include Sexp::Auto::ModuleMethods
    def build syntax_node
      _a = members.map do |m|
        _syntax_node = syntax_node.send(m)
        if _syntax_node.respond_to?(:tree)
          _syntax_node.tree
        else
          _syntax_node.text_value
        end
      end
      new(*_a)
    end
  end
  module Sexp::Auto::Lossless::InstanceMethods
    def unparse
      map do |child|
        if ::String === child
          child
        else
          fail('implement me')
        end
      end.join('')
    end
  end
end
