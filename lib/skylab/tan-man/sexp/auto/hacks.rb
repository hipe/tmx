module Skylab::TanMan
  module Sexp::Auto::Hacks
    # pure container module for holding automagic "hacks"
  end

  class Sexp::Auto::Hack < ::Struct.new :block, :state
    # A commitable hack object (just a simple block-wrapping state machine),
    # it separates the matching of a hack from the application of a hack.

    def commit!
      :uncommitted == state or fail "won't commit the same hack twice"
      res = block.call
      self.state = :commited
      res
    end

  private

    def initialize &b
      self.block = b
      self.state = :uncommitted
    end
  end


  class Sexp::Auto::Hack

    o = { }                                    # like constants

    o[:list_rx] = /\A(?<stem>.+)_list\z/

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze

  end


  module Sexp::Auto::Hack::ModuleMethods
    def define_items_method klass, stem
      items_method = "#{ stem }s".intern # #pluralize
      klass.instance_methods.include?(items_method) and fail "sanity - #{
        }name collision during hack: \"#{items_method
        }\" method is already defined."
      klass.send( :define_method, items_method ) { self._items }
        # future-proof the method's inheritability. also, too #opaque?
      nil
    end
  end


  # --*--


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
    # results in an enumerable that will yield the child trees you seek.
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


    members = [:head, :tail]

    define_singleton_method :match do |i|
      if ( members - i.members_of_interest ).empty? # members incl. head & tail
        Sexp::Auto::Hack.new { enhance i }
      end
    end


    list_rx = Sexp::Auto::Hack::FUN.list_rx

    define_singleton_method :enhance do |i| # `i` for "inference"
      tree_class = i.tree_class
      tree_class._hacks.push :HeadTail #debugging-feature-only
      tree_class.send :include, Sexp::Auto::Hacks::HeadTail::InstanceMethods

      head = i._node.head or fail 'for this hack to work, head: must exist'

      md = list_rx.match i.rule.to_s
      use_stem = nil
      if md
        use_stem = md[:stem].intern
      else
        head_inference = Sexp::Auto::Inference.get head, tree_class, :head
        if head_inference.expression?
          use_stem = head_inference.rule
        else
          fail "for this hack to work your rule name must end in _list #{
            }(your rule name: #{ i.expression })"
        end
      end

      define_items_method tree_class, use_stem
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

  # -- * --

  module Sexp::Auto::Hacks::MemberName
    # This hack simply states: If the rule component has a name that
    # ends in '_text_value', then the treeification strategy for it is simply
    # to call 'text_value' (to get the result string) of the syntax node.

  end

  module Sexp::Auto::Hacks::MemberName::Methods
    Sexp::Auto::Hacks::MemberName.extend self

    rx = /\A(?<stem>.+)_text_value\z/
    define_method :matches? do |name|
      rx =~ name
    end

    def tree inference
      inference._node.text_value
    end
  end
end
