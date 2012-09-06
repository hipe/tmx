module Skylab::TanMan
  module Sexp::Auto end
  class Sexp::Auto::Inference < ::Struct.new(
    :grammar_module, :nt_const, :sexps_module, :syntax_node )

    CONST_RX = /[^0-9]+(?=[0-9]+\z)/

    def self.[] syntax_node
      a = syntax_node.singleton_class.ancestors
      if ::Treetop::Runtime::SyntaxNode == a.first # ick sorry
        return # hm
        # fail("sanity -- you let an alternation node thru")
      end
      consts = a.first.to_s.split('::')
      user_mod = consts[0..-3].reduce(::Object) { |k, c| k.const_get c }
      unless user_mod.const_defined?(:Sexps)
        user_mod.const_set(:Sexps, ::Module.new)
      end
      new(
        user_mod.const_get(consts[-2]),
        CONST_RX.match(consts[-1])[0],
        user_mod.const_get(:Sexps),
        syntax_node
      )
    end
    alias_method :sexp_const, :nt_const
  end
  module Sexp::Auto::Builder end
  module Sexp::Auto::Builder::Methods
    include Sexp::Inflection::InstanceMethods # symbolize
    def [] syntax_node
      i = Sexp::Auto::Inference[ syntax_node ]
      if ! i
        text = syntax_node.text_value
        if /\A[ \t\r\n]*\z/ =~ text
          return text
        end
        fail('what the hell am i doing')
      end
      if ! eval("defined? i.sexps_module::#{i.sexp_const}") # 2 reasons
        klass = build_class i
        klass.nt_const = i.nt_const
        klass.nt_name = symbolize i.nt_const
        i.sexps_module.const_set(i.sexp_const, klass)
      end
      i.sexps_module.const_get(i.sexp_const).build i
    end
    def build_class i
      of_interest = instance_methods_of_interest i
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
      klass
    end
    def instance_methods_module ; nil end
    def instance_methods_of_interest i
      _mod = module_of_interest i
      _mod.instance_methods.select { |k| /\d/ !~ k.to_s }
    end
    def module_methods_module ; Sexp::Auto::ModuleMethods end
    def module_of_interest i
      # To do our magic we need the topmost (rootmost) treetop-generated
      # module.  This is the module with the method names (NT names) of
      # significance.  Hackishly, we skip over user-defined inline
      # method definitions by detecting for a method called 'tree'.
      # This is aggregious.
      a = [] ; n = 0
      begin
        a.push i.grammar_module.const_get("#{i.nt_const}#{n}")
      end while i.grammar_module.const_defined?("#{i.nt_const}#{n += 1}")
      a[-1].method_defined?(:tree) ? a[-2] : a[-1]
    end
  end
  Sexp::Auto.extend Sexp::Auto::Builder::Methods
  module Sexp::Auto::ModuleMethods
    def build i
      syntax_node = i.syntax_node
      new(* members.map { |m| syntax_node.send(m).tree } )
    end
    def list? ; false end
    attr_accessor :nt_const, :nt_name
  end
  module Sexp::Auto::List end
  module Sexp::Auto::List::ModuleMethods
    include Sexp::Auto::ModuleMethods
    def build i
      new( [i.syntax_node.first.tree] +
            i.syntax_node.rest.elements.map { |o| o.content.tree } )
    end
    def list? ; true end
  end
  # --*--
  module Sexp::Auto::Lossless end
  module Sexp::Auto::Lossless::BuilderMethods
    include Sexp::Auto::Builder::Methods
    def build_class i
      # this is ridiculously sinful but useful: use object_id's of syntax
      # nodes to determine positionally which node labels go where.
      # (those children elements that are not labelled get called e0..en)

      rev_map = { } ; eg = i.syntax_node
      meths = instance_methods_of_interest i
      meths.each do |m|
        syn_node = eg.send(m) or fail('sanity')
        rev_map[syn_node.object_id] = m
      end
      members_of_interest = []
      names = eg.elements.each_with_index.map do |syn_node, idx|
        if rev_map.key? syn_node.object_id
          method_name = rev_map[syn_node.object_id]
          members_of_interest.push method_name
          method_name
        else
          "e#{idx}".intern
        end
      end
      me = self
      klass = ::Struct.new(*names).class_eval do
        extend me.module_methods_module
        @members_of_interest = members_of_interest # careful!
        me.instance_methods_module and include(me.instance_methods_module)
        self
      end
      # if there's a two we want a one and a zero
      # no, actually, we just text_value them. change your grammar
      klass
    end
    def instance_methods_of_interest i
      _mod = module_of_interest i
      _mod.instance_methods
    end
    def instance_methods_module ; Sexp::Auto::Lossless::InstanceMethods end
    def module_methods_module   ; Sexp::Auto::Lossless::ModuleMethods end
  end
  Sexp::Auto::Lossless.extend Sexp::Auto::Lossless::BuilderMethods
  module Sexp::Auto::Lossless::ModuleMethods
    include Sexp::Auto::ModuleMethods
    def build i
      _a = members.map do |m|
        sn = i.syntax_node.send m
        if sn.respond_to? :tree
          sn.tree
        else
          sn.text_value
        end
      end
      new(*_a)
    end
  end
  module Sexp::Auto::Lossless::InstanceMethods
    def unparse
      map do |child|
        case child
        when ::NilClass ; child.to_s
        when ::String   ; child
        else            ; child.unparse
        end
      end.join('')
    end
  end
  # --*--
  module Sexp::Auto::Lossless::Recursive end
  module Sexp::Auto::Lossless::Recursive::BuilderMethods
    include Sexp::Auto::Lossless::BuilderMethods
    def module_methods_module
      Sexp::Auto::Lossless::Recursive::ModuleMethods
    end
  end

  Sexp::Auto::Lossless::Recursive.
    extend Sexp::Auto::Lossless::Recursive::BuilderMethods

  module Sexp::Auto::Lossless::Recursive::ModuleMethods
    include Sexp::Auto::Lossless::ModuleMethods
    def build i
      norm_f = ->(s) { '' == s ? nil : s } # easier boolean logic
      elements = i.syntax_node.elements
      a = members.each_with_index.map do |m, idx|
        sn = elements[idx] or fail('sanity')
        if sn.respond_to? :tree
          sn.tree
        elsif sn.elements && members_of_interest.include?(m)
          Sexp::Auto::Lossless::Recursive[ sn ] # the recursive call
            # (just try and make this extensible i dare you)
        else
          norm_f[ sn.text_value ]
        end
      end
      new(*a)
    end
    attr_reader :members_of_interest
  end
end
