module Skylab::TanMan
  module Sexp::Auto end
  class Sexp::Auto::Inference < ::Struct.new(
    :grammar_module, :members_of_interest,
    :nt_const, :sexps_module, :syntax_node
  )
    include Sexp::Inflection::InstanceMethods # symbolize

    CACHE = { } # syntax node object_id to self instance

    CONST_RX = /[^0-9]+(?=[0-9]+\z)/

    def self.[] syntax_node
      CACHE.key?(syntax_node.object_id) and return CACHE[syntax_node.object_id]
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
      CACHE[syntax_node.object_id] = new(
        user_mod.const_get(consts[-2]),
        nil,
        CONST_RX.match(consts[-1])[0],
        user_mod.const_get(:Sexps),
        syntax_node
      )
    end
    alias_method :sexp_const, :nt_const
    def nt_name ; symbolize nt_const end
  end
  module Sexp::Auto::Builder end
  module Sexp::Auto::Builder::Methods

    def [](syntax_node) ; build_tree(syntax_node) end

    def build_tree syntax_node
      i = Sexp::Auto::Inference[ syntax_node ]
      if ! i
        whitespace syntax_node # ..
      else
        if ! i.sexps_module.const_defined? i.sexp_const, false
          klass = build_tree_class i
          klass.nt_const = i.nt_const ; klass.nt_name = i.nt_name
          i.sexps_module.const_set i.sexp_const, klass
        end
        klass ||= i.sexps_module.const_get i.sexp_const, false
        klass.build i
      end
    end

    def build_tree_class i
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
    def whitespace syntax_node
      # this needs to be covered and documented or removed #todo
      text = syntax_node.text_value
      if /\A[ \t\r\n]*\z/ =~ text
        text
      else
        fail('what the hell am i doing')
      end
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
    HEAD_TAIL_RX = /\A(?<stem>.+)_list\z/
    def add_instance_methods i, klass
      klass.class_eval do
        include Sexp::Auto::Lossless::InstanceMethods
        if ([:head, :tail] - i.members_of_interest).empty?
          include Sexp::Auto::HeadTail::InstanceMethods
          md = HEAD_TAIL_RX.match(i.nt_name.to_s) or
            fail("for automagic to work, need _list name, not \"#{i.nt_name}\"")
          items_method = "#{md[:stem]}s".intern
          instance_methods.include?(items_method) and fail('sanity')
          define_method(items_method) { self.items } # future-proof the method
        end
      end
    end
    def build_tree_class i
      # this is ridiculously sinful but useful: use object_id's of syntax
      # nodes to determine positionally which node labels go where.
      # (those children elements that are not labelled get called e0..eN)

      eg = i.syntax_node
      i.members_of_interest and fail('sanity')
      i.members_of_interest = instance_methods_of_interest i
      method_from_node_id = i.members_of_interest.reduce( { } ) do |memo, meth|
        _syntax_node = eg.send(meth) or fail('sanity')
        memo[_syntax_node.object_id] = meth
        memo
      end
      names = eg.elements.each_with_index.map do |syn_node, idx|
        if method_from_node_id.key? syn_node.object_id
          method_from_node_id[syn_node.object_id]
        else
          "e#{idx}".intern
        end
      end
      builder = self
      klass = ::Struct.new(*names).class_eval do
        extend builder.module_methods_module
        @members_of_interest = i.members_of_interest.dup # careful!
        builder.add_instance_methods i, self
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

  module Sexp::Auto::HeadTail end
  module Sexp::Auto::HeadTail::InstanceMethods
    def items
      a = [ ]
      _items a
      a
    end
    def _items a
      head = self.head and a.push(head)
      if tail = self.tail
        tail.class == self.class or fail('sanity') # for now
        tail._items a
      end
      nil
    end
  end
end
