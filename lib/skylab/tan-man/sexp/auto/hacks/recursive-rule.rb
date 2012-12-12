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
      stem = stem.intern ; item_getter = item_getter.intern
      tail_getter = tail_getter.intern
      list_getter and list_getter = list_getter.intern
      (METHODS & i.tree_class.instance_methods).empty? or fail('sanity')
      i.tree_class._hacks.push :RecursiveRule #debugging-feature-only
      i.tree_class.send(:include,
                          Sexp::Auto::Hacks::RecursiveRule::SexpInstanceMethods)
      match_f_f = ->(search_item) do
        if ::String === search_item
          ->(node) { search_item == node[item_getter] }
        else
          ->(node) { search_item.object_id == node[item_getter].object_id }
        end
      end

      next_f = if list_getter then
        ->(node) do
          o = node[tail_getter]
          o &&= o[list_getter]
          o
        end
      else
        ->(node) { node[tail_getter] }
      end

      # -- (item insertion helper lambdas) --

      _normalize_item_f = ->(item, proto) do
        if ! (::String === item)         # item is presumably sexp
          item                           # ..and validating it would be hard
        elsif ::String === ( o = proto[item_getter] ) # both strings
          item                           # so again, validating is meh
        else
          p = o.class.grammar.build_parser_for_rule o.class.rule
          node = p.parse(item) or fail("failed to parse item to insert #{
            (p.failure_reason || item).inspect}")
          sexp = proto.class.element2tree node, item_getter
          sexp
        end
      end

      _idx_left_right_f = ->(before_item, existing_a) do
        if before_item
          match_f = match_f_f[ before_item ]
          r, i = existing_a.each.with_index.detect { |x, _| match_f[ x ] }
          r or fail("node to insert before not found.")
          l = 0 == i ? nil : existing_a[i - 1]
        else
          l = existing_a.last # nil IFF adding to empty list
          i = existing_a.length
          r = nil
        end
        [i, l, r]
      end

      _proto_f = ->(me, existing_a, idx) do
        proto_a = me._prototype ? me._prototype._nodes.to_a : existing_a
        proto_a.length < 2 and fail("cannot insert into a list with less #{
          }than 2 items -- need a prototype list, node, item for hack to work.")
        _proto_idx = [1, [idx, proto_a.length - 2].min ].max
        proto_a[_proto_idx]
      end

      _tail_f_f = ->(right, proto) do
        # nasty : we ned to do this before we reassign any members of "left"
        # because left itself may be the prototype node!
        #
        use_tail = if list_getter
          next_f[ proto ] and fail("can't use non-ultimate node in #{
            }prototype for this hack to work.") # .. w/o heavy hacking
          o = proto.__dupe_member tail_getter
          right and o[list_getter] = right
          o
        elsif right
          right
        else
          nil
        end
        ->(_) { use_tail }
      end

      # -- List Item Insertion Lambdas (in ascending order of complexity) --

      _initial_f = ->(me, proto) do
        # The strategy for initial insertion of an item into an empty list
        # ("list controller") is simply to use the defaults for tail_getter
        # and item_getter and for the remaining members, for those that are
        # non-nil make a dupe of the corresponding member from the prototype.
        #
        [me, me, ::Hash.new(->(m){me[m].nil? ? proto.__dupe_member(m) : me[m]})]
      end

      _insert_f = ->(me, proto, left, right) do
        # For inserting an item under an existing parent (left) node ..
        born = me.class.new
        f_h = ::Hash.new ->(m) { proto.__dupe_member m }
        f_h[tail_getter] = _tail_f_f[ right, proto ] # "left" might itself
        # be the prototype so call the above now before you mutate it!
        if list_getter
          left[tail_getter] or fail('sanity -- expecing foo_list here')
          left[tail_getter][list_getter] and (
          left[tail_getter][list_getter].object_id == right.object_id or
            fail('sanity') )
          left[tail_getter][list_getter] = born
        else
          left[tail_getter] && left[tail_getter].object_id != right.object_id &&
            fail('sanity - lol wat am i doing')
          left[tail_getter] = born
        end
        [born, born, f_h]
      end

      _swap_f = ->(root, proto, item) do
        # No left means inserting at root -- an intense hack, see _remove!
        # born lives in second slot, swapping members with root
        born = root.class.new
        f_h = ::Hash.new( ->(m) do # The default behavior for born node members
          swap = root[m]             # is to give them what was once at root,
          root[m] = proto.__dupe_member m # and at the same time do this to root
          swap
        end )
        original_root_tail = root[tail_getter]
        if list_getter && ! next_f[ proto ]
          tail = proto.__dupe_member(tail_getter)
          root[tail_getter] = tail
          tail[list_getter] = born # oh sweet jesus
        else
          root[tail_getter] = born # think how whacktastic this is
        end
        f_h[tail_getter] = ->(_) { original_root_tail }

        original_root_item = root[item_getter]
        f_h[item_getter] = ->(_) { original_root_item }
        root[item_getter] = _normalize_item_f[ item, proto ]

        [root, born, f_h]
      end

      i.tree_class.send(:define_method, :_insert_before!) do |item, before_item|
        existing_a = _nodes.to_a
        idx, left, right = _idx_left_right_f[ before_item, existing_a ]
        proto = _proto_f[ self, existing_a, idx ]
        result, target, f_h = if left then _insert_f[  self, proto, left, right]
        elsif right                   then _swap_f[    self, proto, item ]
        else                               _initial_f[ self, proto ] end
        unless f_h.key? item_getter
          use_item = _normalize_item_f[ item, proto ]
          f_h[item_getter] = ->(_) { use_item }
        end
        unless f_h.key? tail_getter
          f_h[tail_getter] = _tail_f_f[ right, proto ]
        end
        self.class._members.each { |m| target[m] = f_h[m][ m ] }
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
              curr_node = next_f[ curr_node ]
            end while curr_node
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
          # list.  The really hacky part is this: given that we want to result
          # in a node that represents what was removed, and we can't actually
          # remove the first node, we swap all the properties of the first and
          # second node (except their "next node" properties) and result in
          # what was once the second node!! ack!
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

    attr_accessor :_prototype     # used in eponymous file

  end
end
