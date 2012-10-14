module Skylab::TanMan
  module Sexp::Auto
    # This module is an experiment in the automatic generation of abstract
    # syntax trees (their classes and then objects) dynamically
    # from the syntax nodes of a parse from a Treetop grammar.
  end

  module Sexp::Auto::Constants
    CUSTOM_PARSE_TREE_METHOD_NAME = :tree
  end

  module Sexp::Auto::BuildMethods
    # These Build Methods build sexps ("trees") from syntax nodes, possibly
    # creating sexp classes as necessary.
    #
    # This module will typically be used as follows: descendant modules of
    # this module will typically be extended by for e.g. toplevel modules in
    # this library, and possibly generated Sexp classes for use in
    # recursive calls to builder methods.

    def [] syntax_node # inheritable API entrypoint
      node2tree syntax_node, nil, nil # no class, no member_name
    end

    def add_instance_methods tree_class
      if instance_methods_module
        tree_class.send :include, instance_methods_module
      end
    end

    NUM_RX = /\d+\z/

    WITH_NUMBERS_F = ->(member) { NUM_RX =~ member.to_s }

    def build_element_names i # extent: * defs, 1 call
      # For this basic auto sexp implementation for deciding what the
      # member names should be, we 1) take the methods
      # of interest and then 2) strip out the ones that end with numbers
      # with the assumption that they are repeated, with the reasoning that
      # if it were important you would put a label on it.
      # Return a frozen doohah.  Do not rely on generated properties of inf.

      i.methods_of_interest.reject(& WITH_NUMBERS_F).freeze
    end

    def build_members_of_interest i
      # For this basic auto sexp implementation we assume that the
      # members of interest are one and the same with all the named members.
      # Return an frozen doohah.  Hacks are not yet run.  Gen'd props are.
      # nil gets you all members
      nil
    end

    def build_tree_class i # extent: solo def, 1 call
      members = build_element_names i
      tree_class = ::Struct.new(* members)
      tree_class.extend module_methods_module
      tree_class._members = members
      tree_class.expression = i.expression
      tree_class.rule = i.rule
      tree_class.members_of_interest = build_members_of_interest(i) || members
      add_instance_methods tree_class
      # There might be issues with hacks with more broad patterns intercepting
      # all potential matches with hacks with more narrow patterns so
      # order might be important here.
      i.tree_class and fail('sanity') ; i.tree_class = tree_class # sorry
      hack =   Sexp::Auto::Hacks::HeadTail.match i # run hacks
      hack ||= Sexp::Auto::Hacks::RecursiveRule.match i
      hack and hack.commit!
      tree_class
    end

    def inference2tree o # extent: solo def, 2 calls
      if o.member && Sexp::Auto::Hacks::MemberName.matches?(o.member)
        Sexp::Auto::Hacks::MemberName.tree o
      elsif o.element_names?
        tree_class = if o.sexps_module.const_defined?(o.sexp_const, false)
          o.sexps_module.const_get o.sexp_const, false
        else
          o.sexps_module.const_set o.sexp_const, build_tree_class(o)
        end
        tree_class.tree o
      else
        # "peek ahead" assuming this might be a semantic kleene group.
        # if any of the children has an extension module, make a generic list.
        # Note that we have *no* parent tree class per above, and no elem name.
        a = if o._node.elements
          o._node.elements.map do |n|
            Sexp::Auto::Inference.get(n, nil, nil)
          end
        end
        if a and a.any? { |x| x.expression? or x.element_names? }
          list = list_class.new a.length
          a.each_with_index { |_inf, idx| list[idx] = inference2tree(_inf) }
          list
        else
          Sexp::Auto::Factories::TextValue.tree o
        end
      end
    end

    def instance_methods_module
      Sexp::Auto::InstanceMethods
    end

    def list_class
      Sexp::Auto::List
    end

    def module_methods_module
      sexp_builder_anchor_module.const_get(:ModuleMethods, false)
    end

    def node2tree node, parent_class, member_name # extent: solo def, 2 calls
      # don't call node.tree because that can call this
      inference2tree Sexp::Auto::Inference.get(node, parent_class, member_name)
    end

    def sexp_builder_anchor_module # experimental
      Sexp::Auto
    end
  end

  Sexp::Auto.extend Sexp::Auto::BuildMethods # e.g. Sexp::Auto[ foo ]

  module Sexp::Auto::ModuleMethods
    # This module or descendant modules will be included by generated
    # Sexp ("tree") classes.

    include Sexp::Auto::Constants # CUSTOM_PARSE_TREE_METHOD_NAME
    include Sexp::Auto::BuildMethods # node2tree et. al

    def element2tree element, member_name # extent: solo def, 2 calls
      if ! element
        nil # typically as a trailing optional node
      elsif element.respond_to? CUSTOM_PARSE_TREE_METHOD_NAME
        element.send CUSTOM_PARSE_TREE_METHOD_NAME # careful!
      else
        node2tree element, self, member_name
      end
    end

    attr_accessor :expression
    def _hacks ; @_hacks ||= [] end #debugging-feature-only
    attr_accessor :_members # our version, separate from the ::Struct nerkiss
    attr_accessor :members_of_interest
    attr_accessor :rule

    def tree inference
      _children = members_of_interest.map do |member|
        element2tree inference._node.send(member), member
      end
      new(* _children)
    end
  end

  module Sexp::Auto::InstanceMethods
    def list? ; false end
  end

  class Sexp::Auto::List < ::Array
    include Sexp::Auto::InstanceMethods # important
    def list? ; true end # used only for sanity checks (?)
  end

  # --*--

  class Sexp::Auto::Inference < ::Struct.new(
    :extension_module_metas,
    :member,
    :_node,
    :_parent_class,
    :tree_class # only used for hacks for now (experimental!!)
  )
    include Sexp::Auto::Constants # CUSTOM_PARSE_TREE_METHOD_NAME (on self, too)

    # The Inference of a synax node is for "inferring" what Sexp class to use
    # for a given node from its extension modules.  We crawl up backwards from
    # the first extension module to infer things like the sexp wrapper module.

    CACHE = { } # for some algorithms we might try look-ahead to infer names

    def self.get node, parent_class, member_name
      if CACHE.key? node.object_id
        i = CACHE[node.object_id]
        i._parent_class.object_id != parent_class.object_id and fail('sanity')
        i.member != member_name and fail('sanity')
        i
      else
        CACHE[node.object_id] = FACTORY_F[node, parent_class, member_name]
      end
    end

    FACTORY_F = ->(node, parent_class, member_name) do
      a = node.extension_modules
      if a.empty? # possibly a kleene group!
        new(nil, member_name, node, parent_class)
      else
        # We have at least one extension module so we can definitely infer
        # a const name. But can we infer the names of the elements?
        # We can if we have 'methods of interest' that would come from an
        # extension module  Note, unfortunately, that we have to sidestep
        # the extension module that gets created by us with a method called
        # [CUSTOM_PARSE_TREE_METHOD_NAME]. It's a dodgy move, but this whole
        # house is dodgy o_O
        i = a.length # left vs. right -- ick!!
        last = [0, i - 2].max # any second to last one
        found = nil
        while (i -= 1) >= last
          methods = a[i].instance_methods
          if ! (methods.empty? or
                methods.include?(CUSTOM_PARSE_TREE_METHOD_NAME)) then
            found = i ; break
          end
        end
        metas = a.map { |mod| Sexp::Auto::ExtensionModuleMeta[mod] }
        if found
          Sexp::Auto::Inference_WithElements.new(
            metas, member_name, node, parent_class, found)
        else
          Sexp::Auto::Inference_WithConst.new(
            metas, member_name, node, parent_class)
        end
      end
    end

    def element_names? # are element names inferrable?
      methods_of_interest?
    end
    def expression? # is the expression name inferrable?
      false
    end
    def members_of_interest
      tree_class.members_of_interest
    end
    def members_of_interest?
      ! tree_class.nil?
    end
    def methods_of_interest? # are we able to determine methods of interest?
      false
    end
    def rule? # is the rule name inferrable?
      false
    end
  end

  class Sexp::Auto::Inference_WithConst < Sexp::Auto::Inference
    # What can we do with a node with one extension module?

    include Sexp::Inflection::InstanceMethods # symbolize, chomp_digits

    def expression
      symbolize(sexp_const.to_s).intern
    end
    def expression?
      true
    end
    def rule
      symbolize(expression_extension_module_meta.tail_stem.to_s).intern
    end
    def rule?
      true
    end

    # Given that the extension modules Foo0, Foo1, Foo2 exist, we infer that
    # there is a non-terminal "foo" for which we will use a sexp class
    # whose constant will  be "Foo" (in some module); and the nonterminal
    # symbol has two constituent child symbols Foo0 and Foo1, for which we will
    # also make Sexp classes with those same names. (So note then that there
    # will *not* be a sexp class called Foo2, rather we just call that one Foo.)
    #
    # (In such a series, the "outermost" node gets the highest number.)
    #
    # So in this example, (using a notation where:
    #   <first em name> => <sexp const name>
    # ) we get:
    #   Foo0 => Foo0, Foo1 => Foo1, BUT : Foo2 => Foo

    STEM = { } # grammar_mod => :Foo => [:Foo0, :Foo1, :Foo2]
    SEXP = { } # grammar_mod => { :Foo3 => :Foo, :Foo2 => :Foo2, ... }
    def sexp_const
      (SEXP[grammar_module] ||= ::Hash.new do |h, const|
        stem = chomp_digits const
        a = (STEM[grammar_module] ||= ::Hash.new do |_h, _stem|
          i = 0 ; _a = [ ] ; gm = grammar_module
          loop do
            _a.push "#{_stem}#{i}".intern
            gm.const_defined?("#{_stem}#{ i += 1 }") or break
          end
          _h[_stem] = _a
        end)[ stem ]
        h[const] = a.last == const ? stem.intern : const
      end)[expression_extension_module_meta.tail_const]
    end

    def sexps_module
      # auto-vivify a module to hold generated sexps
      anchor_module.const_defined?(:Sexps, false) ?
        anchor_module.const_get(:Sexps, false) :
        anchor_module.const_set(:Sexps, ::Module.new)
    end
  protected
    def anchor_module
      expression_extension_module_meta.anchor_module
    end
    def grammar_module
      expression_extension_module_meta.grammar_module
    end
    def expression_extension_module_meta
      extension_module_metas.last
      # to see why this is last and not first, see test grammr 60
    end
  end

  class Sexp::Auto::Inference_WithElements < Sexp::Auto::Inference_WithConst
    def methods_of_interest
      extension_module_metas[methods_idx].module.instance_methods
    end
    def methods_of_interest?
      true
    end
  protected
    def initialize *a, methods_idx
      @methods_idx = methods_idx
      super(*a)
    end
    attr_reader :methods_idx
  end

  class Sexp::Auto::ExtensionModuleMeta
    # There are so many inflection-heavy hacks going on that it is useful
    # to have this wrapper around extension modules.  Note we flyweight them.

    include Sexp::Inflection::InstanceMethods

    CACHE = ::Hash.new { |h, mod| h[mod] = new mod }

    def self.[] mod ; CACHE[mod] end

  public
    def anchor_module
      @anchor_module ||=
        _parts[0..-3].reduce(::Object) { |m, x| m.const_get(x, false) }
    end

    def grammar_module
      @grammar_module ||= anchor_module.const_get(grammar_const, false)
    end

    def inspect #debugging-feature-only
      "#<ExtMod:#{tail_const}>"
    end

    attr_reader :module

    def tail_const
      @tail_const ||= _parts[-1].intern
    end

    def tail_stem
      @tail_stem ||= chomp_digits(tail_const)
    end

  protected
    def initialize mod
      @module = mod
    end

    def grammar_const
      _parts[-2]
    end

    def _parts
      @_parts ||= @module.to_s.split('::')
    end
  end

  # --*--

  module Sexp::Auto::Factories
    # experimental namespace for 'static' factories
  end

  module Sexp::Auto::Factories::TextValue ; end

  module Sexp::Auto::Factories::TextValue::Methods
    def tree o
      s = o._node.text_value
      '' == s ? nil : s # easier boolean logic
    end
    Sexp::Auto::Factories::TextValue.extend self
  end

  # --*--

  module Sexp::Auto::Lossless
    # "lossless" means the sexp can recreate faithfully (losslessly) the
    # entirety of the source input string.
    #
  end

  module Sexp::Auto::Lossless::BuildMethods ; include Sexp::Auto::BuildMethods

    def build_element_names i # extent: * defs, 1 call
      # This is ridiculously sinful but useful (experimental, too):
      #
      # In theory, for any given syntax node that corresponds to a rule
      # component (that is, the syntax node has an extension module that
      # we can derive the rule name and component number from), such syntax
      # nodes will always have a fixed number of (possibly nil) children
      # elements (specifically, it has an "elements" array).
      #
      # (As a corollary, then, the syntax nodes that represent Kleene groups
      # do not have extension modules -- they have a variable number of
      # elements.  All of this might be wrong.)
      #
      # So here's the sinful part: we use object_id's of child syntax
      # nodes to determine positionally which node labels go where.
      # Those children elements without easily derivable names will be
      # labeled e0..eN, where N is the offset of the element (so the N's
      # of the eN elements will not necessarily be contiguous numbers.)

      node_id_to_method = { }
      # first iterate over the methods of interest
      i.methods_of_interest.each do |meth|
        _node = i._node.send(meth) or fail('sanity - member of int. must exist')
        node_id_to_method[_node.object_id] = meth
      end
      # then iterate over all the elements
      i._node.elements.each_with_index.map do |syn_node, idx|
        node_id_to_method[syn_node.object_id] || "e#{idx}".intern
      end
    end

    def build_members_of_interest i
      i.methods_of_interest.reject(& WITH_NUMBERS_F).freeze # again, sic
    end

    def instance_methods_module
      Sexp::Auto::Lossless::InstanceMethods
    end

    def list_class
      Sexp::Auto::Lossless::List
    end
  end

  Sexp::Auto::Lossless.extend Sexp::Auto::Lossless::BuildMethods

  module Sexp::Auto::Lossless::ModuleMethods
    include Sexp::Auto::ModuleMethods
  end

  module Sexp::Auto::Lossless::InstanceMethods
    include Sexp::Auto::InstanceMethods
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

  class Sexp::Auto::Lossless::List < Sexp::Auto::List
    include Sexp::Auto::Lossless::InstanceMethods
  end

  # --*--

  module Sexp::Auto::Lossless::Recursive end

  module Sexp::Auto::Lossless::Recursive::BuildMethods
    include Sexp::Auto::Lossless::BuildMethods

    Sexp::Auto::Lossless::Recursive.extend self # a toplevel entrypoint for
                                                # these builder methods

    def sexp_builder_anchor_module
      Sexp::Auto::Lossless::Recursive
    end
  end

  module Sexp::Auto::Lossless::Recursive::ModuleMethods
    include Sexp::Auto::Lossless::ModuleMethods
    include Sexp::Auto::Lossless::Recursive::BuildMethods # for #recursive call

    def tree inference # the #recursive call
      elements = inference._node.elements
      (_members.length == elements.length) or fail('sanity: wrong # of els')
      _children = elements.zip(_members).map do |element, member|
        element2tree element, member
      end
      new(* _children)
    end
  end

  # --*--

  module Sexp::Auto::Hacks
    # pure container module for holding automagic "hacks"
  end

  class Sexp::Auto::Hack < ::Struct.new(:block, :state)
    # A commitable hack object (just a simple block-wrapping state machine),
    # it separates the matching of a hack from the application of a hack.

    def commit!
      :uncommitted == state or fail("won't commit the same hack twice")
      result = block.call
      self.state = :commited
      result
    end
  protected
    def initialize &b
      self.block = b
      self.state = :uncommitted
    end
  end

  module Sexp::Auto::Hack::ModuleMethods
    def define_items_method klass, stem
      items_method = "#{stem}s" # pluralize
      klass.instance_methods.include?(items_method) and fail("sanity -#{
        } name collision during hack: \"#{items_method
        }\" method is already defined.")
      klass.send(:define_method, items_method) { self._items }
        # future-proof the method's inheritability. also, too #opaque?
      nil
    end
  end

  module Sexp::Auto::Hack::Constants
    LIST_RX = /\A(?<stem>.+)_list\z/
  end

  module Sexp::Auto::Hacks::HeadTail
    # This HeadTail hack is similar but different from the RecursiveRule hack
    # thus: they both represent alternate ways to define lists in grammars.
    # In this pattern a list is accomplished by use of a kleene star.
    # The other form achieves a list-like pattern with eponymous recursion.
    #
    # This, the HeadTail hack, works and has features as follows:
    #
    # It will enhance a tree class for an example syntax node that matches
    # the property that (at this level) the node has the labels
    # "head:" and "tail:" (it can have other labels).
    #
    # We enhance the resulting tree class as follows: we include unto it
    # a module that defines a method called "_items" that presumably
    # returns an enumerable that will yield the child trees you seek.
    #
    # Also, as a possibly too #opaque added bonus, we will effectively
    # alias the above mentioned "_items" method to a business-specific name we
    # infer by adding an 's' to an inferred stem that we derive from:
    #
    #   - If the rule name is of the form "foo_list" we infer the stem "foo"
    #   - else if an inference can be made of the syntax node that is under the
    #     "head' label, we infer the stem from that
    #     (#todo the above sucks and must be removed.  such lists should be
    #     possibly zero-length and as such this is a non-deterministic hack.
    #     *unless* of course the only time (and hence first time)
    #     this hack is triggered is when it is with a list that is nonzero
    #     in length.)
    #   - else we will fail
    #

    extend Sexp::Auto::Hack::ModuleMethods
    include Sexp::Auto::Hack::Constants

    MEMBERS = [:head, :tail]
    def self.match i
      if ( MEMBERS - i.members_of_interest ).empty? # members incl. head & tail
        Sexp::Auto::Hack.new { enhance i }
      end
    end

    def self.enhance i # inference
      i.tree_class._hacks.push :HeadTail #debugging-feature-only
      i.tree_class.send(:include, Sexp::Auto::Hacks::HeadTail::InstanceMethods)

      head = i._node.head or fail('for this hack to work, head: must exit')
      if md = LIST_RX.match(i.rule.to_s)
        use_stem = md[:stem].intern
      else
        head_inference = Sexp::Auto::Inference.get(head, i.tree_class, :head)
        if head_inference.expression?
          use_stem = head_inference.rule
        else
          fail("for this hack to work your rule name must end in _list #{
          }(your rule name: #{i.expression})")
        end
      end
      define_items_method i.tree_class, use_stem
      true
    end
  end
  module Sexp::Auto::Hacks::HeadTail::InstanceMethods
    def _items
      a = [ ] ; __items a ; a
    end

    # we are experimenting with different patterns for this (as seen in
    # the various grammars in the unit tests), so this is all subject to change.
    def __items y
      head = self.head ; tail = self.tail
      head and y << head
      if ! tail
        # nothing
      elsif tail.list?
        tail.each do |tree|
          y << tree.content
        end
      elsif tail.class.expression == self.class.expression
        # foo_list ::= (s? head:foo s? ';'? '?' tail:foo_list?)?
        tail.__items y
      else
        # foo_list ::= (head:foo tail:(sep content:foo_list)? sep?)?
        if tail.class.rule != self.class.rule
          # this used to be an issue, is it not any more!?
          # fail('sanity - this does not look recursive')
        end
        if tail.content
          tail.content.class.expression == self.class.expression or fail('sanity')
          tail.content.__items y
        end
      end
      nil
    end
  end
  # ---*---
  module Sexp::Auto::Hacks::RecursiveRule
    # This hack matches a node that matches the first of a series of patterns:
    # 1) if a rule has an element that itself has the same name as the rule
    # 2) if the rule is named "foo_list" and has a "foo" as an element
    #     (a member called "tail" is then assumed that itself must have
    #      a member called "foo_list")

    extend Sexp::Auto::Hack::ModuleMethods
    include Sexp::Auto::Hack::Constants

    def self.match i
      if i.members_of_interest?
        if i.members_of_interest.include? i.rule # "foo" rule with "foo" element
          Sexp::Auto::Hack.new { enhance i, :content, i.rule }
        elsif md = LIST_RX.match(i.rule.to_s) # "foo_list" rule with "foo" elem
          if i.members_of_interest.include? md[:stem].intern
            Sexp::Auto::Hack.new { enhance i, md[:stem].intern, :tail, i.rule }
          end
        end
      end
    end

    def self.enhance i, item_getter, tail_getter, list_getter=nil
      i.tree_class._hacks.push :RecursiveRule #debugging-feature-only
      i.tree_class.instance_methods.include?(:_items) and fail('sanity')
      i.tree_class.send(:define_method, :_items) do
        y = [ ]
        node = self
        begin
          _item = node.send(item_getter) or fail('sanity')
          y << _item
          if _tail_node = node.send(tail_getter)
            node = _tail_node
            if list_getter # ick but more logically readable
              node = node.send(list_getter)
            end
          else
            node = nil
          end
        end while node
        y
      end
      define_items_method i.tree_class, item_getter
      nil
    end
  end
  # ---*---
  module Sexp::Auto::Hacks::MemberName
    # This hack simply states: If the rule component has a name that
    # ends in '_text_value', then the treeification strategy for it is simply
    # to call 'text_value' (to return the string) of the syntax node.

  end
  module Sexp::Auto::Hacks::MemberName::Methods
    Sexp::Auto::Hacks::MemberName.extend self

    RX = /\A(?<stem>.+)_text_value\z/
    def matches? name
      RX =~ name
    end

    def tree inference
      inference._node.text_value
    end
  end
  # --*--
  class Sexp::Auto::ContentTextValue < ::Struct.new(:content_text_value)
    # This is a tree building strategy that: gives you a struct
    # with a single member called content_text_value that holds
    # the text_value of the syntax node. Experimental!
    def self.[] syntax_node
      super syntax_node.text_value
    end
    alias_method :unparse, :content_text_value
  end
end
