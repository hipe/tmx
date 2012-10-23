module Skylab::TanMan
  module Sexp::Auto::Hacks::RecursiveRule
    # This hack matches a node that matches the first of a series of patterns:
    # 1) if a rule has an element that itself has the same name as the rule
    # 2) if the rule is named "foo_list" and has a "foo" as an element
    #     (a member called "tail" is then assumed that itself must have
    #      a member called "foo_list")
    # A large portion of the hack is dedicated to an experimental mutation API

    extend Sexp::Auto::Hack::ModuleMethods
    include Sexp::Auto::Hack::Constants

    def self.match i
      if i.members_of_interest?
        md = LIST_RX.match(i.rule.to_s)
        if i.members_of_interest.include? i.rule # "foo" rule with "foo" element
          Sexp::Auto::Hack.new do
            enhance i, (md ? md[:stem] : i.rule), :content, i.rule
          end
        elsif md # "foo_list" rule with "foo" elem
          if i.members_of_interest.include? md[:stem].intern
            Sexp::Auto::Hack.new do
              enhance i, md[:stem], md[:stem], :tail, i.rule
            end
          end
        end
      end
    end

    METHODS = [:_append!, :_insert_before!, :_items, :_remove!]

    def self.enhance i, stem, item_getter, tail_getter, list_getter=nil
      (METHODS & i.tree_class.instance_methods).empty? or fail('sanity')
      i.tree_class._hacks.push :RecursiveRule #debugging-feature-only
      i.tree_class.send(:include,
                          Sexp::Auto::Hacks::RecursiveRule::SexpInstanceMethods)
      next_f = match_f_f = nil # forward-declare all these for scope
      match_f_f = ->(search_item) do
        if ::String === search_item
          ->(node) { search_item == node[item_getter] }
        else
          ->(node) { search_item.object_id == node[item_getter].object_id }
        end
      end
      next_f = list_getter ?
        ->(node) { o = node[tail_getter] ; o and o[list_getter] } :
        ->(node) { node[tail_getter] }
      i.tree_class.send(:define_method, :_insert_before!) do |item, before_item|
        all = _nodes.to_a
        all.length < 2 and fail("cannot insert into a list with less than#{
          } two items -- we need a prototype node for this hack to work.")
        left = prototype = right = nil
        if before_item
          match_f = match_f_f[ before_item ]
          right, idx = all.each.with_index.detect { |x, _| match_f[ x ] }
          right or fail("node to insert before not found.")
          left = 0 == idx ? nil : all[idx - 1]
          right = all.detect { |n| match_f[ n ] or (left = n and nil) }
        else
          left = all.last # length was asserted above so this must be non-nil
          idx = all.length
        end
        target = self.class.new
        duplicate_prototype_f = ->(k) do
          case prototype[k]
          when ::NilClass ; nil
          when ::String ; prototype[k].dup
          else ; fail('implement me - complex templatization')
          end
        end
        prototype = all[ [1, [idx, all.length - 2].min ].max ]
        if left
          left[tail_getter] = target
          init_f_h = ::Hash.new( duplicate_prototype_f )
          result = target
        else # inserting at root -- intense, hack similar to _remove! (see)
          right = self[tail_getter]  # newly created will point to current 2nd
          self[tail_getter] = target # root will point to newly created
          swap = self[item_getter]   # hold on to current root content
          self[item_getter] = item   # root now points to new content
          item = swap                # newly created will point to current cont.
          init_f_h = ::Hash.new( ->(k) do
            # for all of these, you want the newly created one to have the
            # actual one that root used to have, and the absence where the
            # root item used to be is is a copy of the template!!!
            _swap = self[k]
            self[k] = duplicate_prototype_f[ k ]
            _swap
          end )
          result = self
        end
        init_f_h[item_getter] = ->(_) { item }
        init_f_h[tail_getter] = ->(_) { right }
        self.class._members.each do |m|
          target[m] = init_f_h[m].call(m)
        end
        result
      end
      i.tree_class.send(:define_method, :_items) do
        _nodes.map { |node| node[item_getter] }
      end
      i.tree_class.send(:define_method, :_nodes) do
        ::Enumerator.new do |y|
          if self[item_getter] # else zero-width tree stub
            curr_node = self
            begin
              y << curr_node
            end while curr_node = next_f[ curr_node ]
          end
          nil
        end
      end
      i.tree_class.send(:define_method, :_remove!) do |search_item|
        match_f = match_f_f[ search_item ] ; parent = nil
        target = _nodes.detect do |node|
          match_f[ node ] or ( parent = node and nil )
        end
        target or fail("node to remove not found.")
        if parent
          parent[tail_getter] = target[tail_getter]
          target[tail_getter] = nil
          target
        else
          # When "removing" the first (root) node of a list (tree), we can't
          # actually remove the node itself because it is a handle to the whole
          # list.  The really hacky part is this: given that we want to return
          # a node that represents what was removed, and we can't actually
          # remove the first node, we swap all the properties of the first and
          # second node (except their "next node" properties) and return what
          # was once the second node!! ack!
          # This mess is kept logically separate because as the idea
          # of zero-width list stubs evolves this might become unnecessary.
          object_id == target.object_id or fail('sanity')
          source = next_f[ target ] || target.class.new
          source.class == target.class or fail('sanity')
          transfer = ::Hash.new( ->(m) { target[m] } )
          transfer[tail_getter] = ->(_) { nil }
          target.class._members.each do |m|
            swap = source[m]
            source[m] = transfer[m].call(m)
            target[m] = swap
          end
          source # this is the sketchy thing! it is a "surrogate angel"
        end
      end
      define_items_method i.tree_class, stem
      nil
    end
  end
  module Sexp::Auto::Hacks::RecursiveRule::SexpInstanceMethods
    def _append! item
      _insert_before! item, nil
    end
    def list?
      true
    end
    attr_accessor :_prototype
    def _prototypify!
      blank_list_controller = self.class.new
      blank_list_controller._prototype = self
      blank_list_controller
    end
  end
end
