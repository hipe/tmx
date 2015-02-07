module Skylab::TanMan

  module Sexp_::Auto

  class Hack_  # stowaway

    # this in an implementation of :#matchdata-pattern: we want to be able to
    # separate the act of matching a hack from the act of applying that hack.
    # so it is a commitable hack object that encapsulates a proc that appiles
    # the hack and as well is a simple 2-state state machine tracking whether
    # or not it has been applied (hacks are single-use only).

    class << self
      def list_rx
        LIST_RX__
      end
    end  # >>

    LIST_RX__ = /\A(?<stem>.+)_list\z/

    def initialize & p
      @p = p
      @state = :uncommitted
    end

    attr_reader :state

    def commit!
      if :uncommitted == @state
        x = @p.call
        @state = :committed
        x
      else
        fail "won't commit the same hack twice"
      end
    end

    module ModuleMethods

      def define_items_method cls, stem  # duplicated over there

        meth_i = :"#{ stem }s".intern  # #pluralize

        if cls.method_defined? meth_i
          fail __say_name_collision meth_i
        else
          cls.send :define_method, meth_i do
            # future-proof the method's inheritability. also, too #opaque?
            self.to_item_array_
          end
        end
        nil
      end
    end
  end  # end stowaway


  # --*--

  Hacks__ = ::Module.new

  module Hacks__::HeadTail

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
    # a module that defines a method called "to_item_array_" that presumably
    # results in an enumerable that will yield the child trees you seek.
    #
    # Also, as a possibly too #opaque added bonus, we will effectively
    # alias the above mentioned "to_item_array_" method to a business-specific name we
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

    extend Hack_::ModuleMethods


    members = [:head, :tail]

    define_singleton_method :match do |i|
      if ( members - i.members_of_interest ).empty? # members incl. head & tail
        Hack_.new { enhance i }
      end
    end


    list_rx = Hack_.list_rx

    define_singleton_method :enhance do |i| # `i` for "inference"
      tree_class = i.tree_class
      tree_class._hacks.push :HeadTail #debugging-feature-only
      tree_class.send :include, Instance_Methods___

      head = i._node.head or fail 'for this hack to work, head: must exist'

      md = list_rx.match i.rule.to_s
      use_stem = nil
      if md
        use_stem = md[:stem].intern
      else
        head_inference = Auto_::Inference.get head, tree_class, :head
        if head_inference.the_expression_name_is_inferrable
          use_stem = head_inference.rule
        else
          fail "for this hack to work your rule name must end in _list #{
            }(your rule name: #{ i.expression })"
        end
      end

      define_items_method tree_class, use_stem
      true
    end

  module Instance_Methods___

    def to_item_array_
      a = []
      yield_items_into_ a
      a
    end

    # we are experimenting with different patterns for this (as seen in
    # the various grammars in the unit tests), so this is all subject to change.

    def yield_items_into_ y
      head = self.head ; tail = self.tail
      head and y << head
      if ! tail
        # nothing
      elsif tail.is_list_
        tail.each do |tree|
          y << tree.content
        end
      elsif tail.class.expression == self.class.expression
        # foo_list ::= (s? head:foo s? ';'? '?' tail:foo_list?)?
        tail.yield_items_into_ y
      else
        # foo_list ::= (head:foo tail:(sep content:foo_list)? sep?)?
        if tail.class.rule != self.class.rule
          # this used to be an issue, is it not any more!?
          # fail('sanity - this does not look recursive')
        end
        if tail.content
          tail.content.class.expression == self.class.expression or fail('sanity')
          tail.content.yield_items_into_ y
        end
      end
      nil
    end
  end
  end

  # -- * --

  module Hacks__::MemberName

    # This hack simply states: If the rule component has a name that
    # ends in '_text_value', then the treeification strategy for it is simply
    # to call 'text_value' (to get the result string) of the syntax node.


    extend ( module Methods

      def hack_matches_member_name name_symbol
        RX___ =~ name_symbol
      end

      def tree inference
        inference._node.text_value
      end

      self
    end )

    RX___ = /\A(?<stem>.+)_text_value\z/
  end
  end
end
