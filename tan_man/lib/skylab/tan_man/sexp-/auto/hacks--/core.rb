module Skylab::TanMan

  module Sexp_::Auto

    Hacks__ = ::Module.new

    module HackSupport_  # because the Hacks__ module is (uselessly) a cordoned-off collection module

      module Auto_::Hacks__::HeadTail

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
    #     (#wont-fix the above sucks and must be removed.  such lists should be
    #     possibly zero-length and as such this is a non-deterministic hack.
    #     *unless* of course the only time (and hence first time)
    #     this hack is triggered is when it is with a list that is nonzero
    #     in length.)
    #   - else we will fail
    #
        def self.match_inference o

          # enhance the tree class with this hack IFF members of interest
          # include `head` and `tail`

          _d = ( THESE___ - o.members_of_interest ).length

          if _d.zero?  # (the number of items that weren't in the list)
            -> { Enhance___[ o ] }
          end
        end

        THESE___ = [ :head, :tail ]

        Enhance___ = -> o do  # inference

          cls = o.tree_class
          cls.include HeadTailInstanceMethods___

          head = o.syntax_node.head
          head || self._SANITY__for_this_hack_to_work__head_must_exist__

          md = LIST_RX.match o.to_rule_symbol_
          if md
            stem = md[ :stem ].intern
          else
            head_inference = Inference_for_[ head, cls, :head ]
            head_inference || self._SANITY__readme__
              # for this hack to work, your rule name must end int `_list`
            stem = head_inference.to_rule_symbol_
          end

          Define_items_method___[ cls, stem ]
          NIL
        end

        module HeadTailInstanceMethods___

          def to_item_array_
            _write_items_into []
          end

    # we are experimenting with different patterns for this (as seen in
    # the various grammars in the unit tests), so this is all subject to change.

          def _write_items_into y

      head = self.head ; tail = self.tail
      head and y << head
      if ! tail
        # nothing
      elsif tail.is_list_
        tail.each do |tree|
          y << tree.content
        end
      elsif tail.class.expression_symbol == self.class.expression_symbol
        # foo_list ::= (s? head:foo s? ';'? '?' tail:foo_list?)?
        tail._write_items_into y
      else
        # foo_list ::= (head:foo tail:(sep content:foo_list)? sep?)?
        if tail.class.rule_symbol != self.class.rule_symbol
          # this used to be an issue, is it not any more!?
          # fail('sanity - this does not look recursive')
        end
        if tail.content
          tail.content.class.expression_symbol == self.class.expression_symbol || self._SANITY
          tail.content._write_items_into y
        end
      end
            y
          end  # the def
        end  # head tail instance methods
      end  # end hack

  # -- * --

      module Auto_::Hacks__::MemberName

        # this hack is simply: if the rule component has a name that ends in
        # `*_text_value`, then the treeification strategy for syntax nodes
        # like these is simply to call `text_value` (to get the result string
        # of the syntax node).

        def self.tree_proc_via_inference__ inf
          mem = inf.member_symbol
          if mem && /\A.+_text_value\z/ =~ mem
            -> do
              inf.syntax_node.text_value
            end
          end
        end
      end  # end hack

      # (now you're in hack support)

      Define_items_method___ = -> cls, stem do

        meth_sym = :"#{ stem }s"  # #pluralize

        if cls.method_defined? meth_sym
          fail __say_name_collision meth_sym  # ..
        else
          cls.send :define_method, meth_sym do
            # future-proof the method's inheritability. also, too #opaque?
            self.to_item_array_
          end
        end
        NIL
      end

      LIST_RX = /\A(?<stem>.+)_list\z/
    end
  end
end
# :#history-A.1
