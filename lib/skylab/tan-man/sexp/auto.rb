module Skylab::TanMan
  module Sexp::Auto
    # This module is an experiment in the automatic generation of useful
    # Struct subclasses for noterminal language elements in a Treetop grammar.
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
      node2tree syntax_node, nil
    end

    def add_instance_methods i
      if instance_methods_module
        i.tree_class.send :include, instance_methods_module
      end
      # There might be issues with hacks with more broad patterns intercepting
      # all potential matches with hacks with more narrow patterns so
      # order might be important here.
      if Sexp::Auto::Hacks::HeadTail.matches? i
        Sexp::Auto::Hacks::HeadTail.enhance i
      elsif Sexp::Auto::Hacks::RecursiveTail.matches? i
        Sexp::Auto::Hacks::RecursiveTail.enhance i
      end
    end

    NUM_RX = /\d+\z/

    def build_tree_class i
      # For this basic auto sexp implementation, we 1) take the methods
      # of interest and then 2) strip out the ones that end with numbers
      # with the assumption that they are repeated, with the reasoning that
      # if it were important you would put a label on it.

      names = i.methods_of_interest.reject { |m| NUM_RX =~ m.to_s }
      i.tree_class = ::Struct.new(*names)
      i.tree_class.extend module_methods_module
      i.tree_class.members_of_interest = names
      add_instance_methods i
      i.tree_class
    end

    def element2tree element, parent_class
      if ! element
        nil # typically as a trailing optional node
      elsif element.respond_to? :tree
        element.tree # for custom definitions e.g. in the grammar (careful!)
      else
        node2tree element, parent_class
      end
    end

    def inference2tree o
      klass = nil
      o.sexps_module.const_defined?(o.sexp_const, false) or begin
        klass = build_tree_class o
        klass.nt_name = o.nt_name
        klass._nt_stem = o._nt_stem
        o.sexps_module.const_set o.sexp_const, klass
      end
      klass ||= o.sexps_module.const_get o.sexp_const, false
      klass.klass2tree o
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

    def node2tree node, parent_class
      # (Don't call node.tree from here.  That calls this.)
      inference = Sexp::Auto::Inference.get(node, parent_class)
      if inference
        inference2tree inference
      else
        uninferrable2tree node, parent_class
      end
    end

    def normalize_text_value s # easier boolean logic
      '' == s ? nil : s
    end

    def sexp_builder_anchor_module # experimental
      Sexp::Auto
    end

    # This one's crazy : "peek ahead" to this node (possibly a kleene group)
    # into the children one level down.  If you can make inferences of them,
    # then use this generic list class to hold a list of them, else collapse.

    def uninferrable2tree node, parent_class
      inferences = node.elements && node.elements.map do |n|
        Sexp::Auto::Inference.get(n, parent_class)
      end
      if ! (inferences && inferences.any?)
        normalize_text_value node.text_value
      else
        list = list_class.new node.elements.length
        node.elements.each_with_index do |n, idx|
          list[idx] = if inferences[idx]
            inference2tree inferences[idx]
          else
            uninferrable2tree n, parent_class
          end
        end
        list
      end
    end
  end

  Sexp::Auto.extend Sexp::Auto::BuildMethods # e.g. Sexp::Auto[ foo ]

  module Sexp::Auto::ModuleMethods
    # This module or descendant modules will be included by generated
    # Sexp ("tree") classes.

    include Sexp::Auto::BuildMethods # the constructor (klass2tree) needs this

    def klass2tree inference
      new(* members_of_interest.map do |m|
          element2tree inference._node.send(m), self
        end
      )
    end

    attr_accessor :members_of_interest
    attr_accessor :nt_name
    attr_accessor :_nt_stem
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
    :em_first,
    :_em_rest,
    :grammar,
    :mod,
    :_parent_class,
    :tree_class
  )
    # The Inference of a synax node is for "inferring" what Sexp class to use
    # for a given node from its extension modules.  We crawl up backwards from
    # the first extension module to infer things like the sexp wrapper module.

    include Sexp::Inflection::InstanceMethods # symbolize

    CACHE = { } # for some algorithms we might try look-ahead to infer names

    def self.get node, parent_class
      if CACHE.key?(node.object_id)
        i = CACHE[node.object_id] # might be nil
        if i
          if i._parent_class.object_id != parent_class.object_id
            fail('sanity')
          end
        end
        i
      else
        CACHE[node.object_id] = inference(node, parent_class)
      end
    end

    def self.inference node, parent_class
      parent_class and (::Class === parent_class or fail("huh? #{parent_class.inspect}"))
      ems = node.extension_modules
      ems.empty? and return nil # possibly a kleene group
      o = new
      o._node = node # not a struct member only to hide it from dumps :/
      o._parent_class = parent_class
      em = ems.shift
      parts = em.to_s.split('::')
      o.em_first = parts.pop.intern
      o._em_rest = ems
      o.grammar = parts.pop.intern
      o.mod = parts.reduce(::Object) { |m, x| m.const_get(x, false) }
      o
    end

    def grammar_module
      mod.const_get grammar, false
    end

    TREE = [:tree]

    def methods_of_interest
      a = grammar_module.const_get(em_first, false).instance_methods
      if TREE == a # WONDERHACK sorry
        a = _em_rest.first.instance_methods
      end
      a
    end

    attr_accessor :_node

    def nt_name
      symbolize(sexp_const.to_s).intern
    end

    def _nt_stem
      symbolize(_stem(em_first).to_s).intern
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
        stem = _stem const
        a = (STEM[grammar_module] ||= ::Hash.new do |_h, _stem|
          i = 0 ; _a = [ ] ; gm = grammar_module
          loop do
            _a.push "#{_stem}#{i}".intern
            gm.const_defined?("#{_stem}#{ i += 1 }") or break
          end
          _h[_stem] = _a
        end)[ stem ]
        h[const] = a.last == const ? stem.intern : const
      end)[em_first]
    end

    def sexps_module
      mod.const_defined?(:Sexps, false) ?
        mod.const_get(:Sexps, false) : mod.const_set(:Sexps, ::Module.new)
    end

    def _stem const
      _md = /\A(?<stem>[^0-9]+)[0-9]+\z/.match(const.to_s) or
        fail("sanity: Expecting this badbody to end in digits: #{const}")
      _md[:stem].intern
    end
  end

  # --*--

  module Sexp::Auto::Lossless
    # "lossless" means the sexp can recreate faithfully (losslessly) the
    # entirety of the source input string.
    #
  end

  module Sexp::Auto::Lossless::BuildMethods ; include Sexp::Auto::BuildMethods

    def build_tree_class i
      # this is ridiculously sinful but useful: use object_id's of child syntax
      # nodes to determine positionally which node labels go where.
      # (those children elements that are not labelled get called e0..eN)

      node_id_to_method = { }
      methods_of_interest = i.methods_of_interest
      methods_of_interest.each do |meth|
        _node = i._node.send(meth) or fail('sanity')
        node_id_to_method[_node.object_id] = meth
      end
      names = i._node.elements.each_with_index.map do |syn_node, idx|
        node_id_to_method[syn_node.object_id] || "e#{idx}".intern
      end
      i.tree_class = ::Struct.new(*names)
      i.tree_class.extend module_methods_module
      i.tree_class.members_of_interest = methods_of_interest
      add_instance_methods i
      i.tree_class
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

    def klass2tree inference # the #recursive call
      new(* inference._node.elements.map { |e| element2tree e, self })
    end
  end

  # --*--

  module Sexp::Auto::Hacks
    # pure container module for holding automagic "hacks"
  end

  module Sexp::Auto::Hacks::HeadTail
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
    #   - else we will fail
    #

    MEMBERS = [:head, :tail]
    def self.matches? i
      ( MEMBERS - i.tree_class.members_of_interest ).empty?
    end

    LIST_RX = /\A(?<stem>.+)_list\z/
    def self.enhance inference
      # (the below hackery is explained in the comment for this module above.)

      head = inference._node.head or
        fail('for this hack to work, head: must exit')

      _use_stem = if ( md = LIST_RX.match(inference._nt_stem.to_s) )
        md[:stem].intern
      elsif ( head_inference = Sexp::Auto::Inference.get(head, inference.tree_class))
        head_inference._nt_stem
      else
        fail("for this hack to work your rule name must end in _list")
      end
      items_method = "#{_use_stem}s"
      inference.tree_class.class_eval do
        include Sexp::Auto::Hacks::HeadTail::InstanceMethods
        instance_methods.include?(items_method) and fail("sanity -#{
          } name collision during HeadTail hack: \"#{instance_methods
          }\" method is already defined.")
        define_method(items_method) { self._items }
          # future-proof the method's inheritability. also, too #opaque?
      end
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
      elsif tail.class.nt_name == self.class.nt_name
        # foo_list ::= (s? head:foo s? ';'? '?' tail:foo_list?)?
        tail.__items y
      else
        # foo_list ::= (head:foo tail:(sep content:foo_list)? sep?)?
        tail.class._nt_stem == self.class._nt_stem or fail('sanity') # for now
        if tail.content
          tail.content.class.nt_name == self.class.nt_name or fail('sanity')
          tail.content.__items y
        end
      end
      nil
    end
  end
  module Sexp::Auto::Hacks::RecursiveTail
    # This hack tries to recognize a rule called "foo_list" that has as
    # one of its members of interest a doohah called foo and then presumably
    # as antoher one of its optional doohahs a doohah called "foo_list"

    LIST_RX = /\A(?<stem>.+)_list\z/

    def self.matches? i
      if _md = LIST_RX.match(i.nt_name.to_s)
        if i.tree_class.members_of_interest.include?(_md[:stem].intern)
          true
        end
      end
    end

    def self.enhance inference
      inference.tree_class.class_eval do
        extend Sexp::Auto::Hacks::RecursiveTail::ModuleMethods
        include Sexp::Auto::Hacks::RecursiveTail::InstanceMethods
        self.item_stem = LIST_RX.match(inference._nt_stem)[:stem].intern
      end
    end
  end
  module Sexp::Auto::Hacks::RecursiveTail::ModuleMethods
    attr_accessor :item_stem
  end
  module Sexp::Auto::Hacks::RecursiveTail::InstanceMethods
    def _items
      a = [ ]
      node = self
      begin
        _item = node.send(self.class.item_stem) or fail('sanity')
        a << _item
        node = if _tail = node.tail
          _tail.send(self.class._nt_stem) # nil ok
        end
      end while node
      a
    end
  end
end
