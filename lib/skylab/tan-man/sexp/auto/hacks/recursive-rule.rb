module Skylab::TanMan
  module Sexp::Auto::Hacks::RecursiveRule
    # This hack matches a node that matches the first of a series of patterns:
    # 1) if a rule has an element that itself has the same name as the rule
    # 2) if the rule is named "foo_list" and has a "foo" as an element
    #     (a member called "tail" is then assumed that itself must have
    #      a member called "foo_list")
    # A large portion of the hack is dedicated to an experimental mutation API

    extend Sexp::Auto::Hack::ModuleMethods


    list_rx = Sexp::Auto::Hack::FUN.list_rx  # ( any name that ends in "_list" )

    define_singleton_method :match do |i|
      if i.members_of_interest?
        md = list_rx.match i.rule.to_s
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


    methods = [:_append!, :_insert_before!, :_items, :_remove!]

    define_singleton_method :enhance do |i, stem, item_getter,
                                           tail_getter, list_getter=nil|

      # #experimental'y functional - everything is here
      tree_class = i.tree_class

      (methods & tree_class.instance_methods).empty? or fail 'sanity'
                                               # be sure we're not overwriting

      item_getter = item_getter.intern         # normalize every actual param
      list_getter = list_getter.intern if list_getter
      stem = stem.intern
      tail_getter = tail_getter.intern



      tree_class._hacks.push :RecursiveRule    # #debugging-feature-only
      tree_class.send :include,
                          Sexp::Auto::Hacks::RecursiveRule::SexpInstanceMethods

      match_f = -> search_item do              # a function to make matcher
        if ::String === search_item            # functions for matching nodes
          -> node { search_item == node[item_getter] }  # that new nodes are
        else                                   # supposed to come before / after
          -> node { search_item.object_id == node[item_getter].object_id }
        end
      end

      next_node = if list_getter then          # determining what is the next
        -> node do                             # node after a node is different
          o = node[tail_getter]                # based on whether or not there
          o &&= o[list_getter]                 # is a tail getter
          o
        end
      else
        -> node { node[tail_getter] }
      end


      # -- Item insertion lambdas

      normalize_item = -> item, proto do       # normalize the item for insert
        res = nil                              # (parsing string if necessary)
        begin
          if ! (::String === item)             # then item is presumably a sexp
            break( res = item )                # and validating it would be
          end                                  # prohibitively annoying
          o = proto[ item_getter ]
          if ::String === o                    # the elem in the proto is also
            break( res = item )                # a string, they both are, so
          end                                  # again validating is meh

          # item is string and proto elem is not string, assume we are to parse
          res = o.class.parse o.class.rule, item, -> failed_parser do
            fail "failed to parse item to insert - #{
              }#{ ( failed_parser.failure_reason || item ).inspect }"
          end

        end while nil
        res
      end
                                               # what is the index, the left
                                               # and right node of the new node
                                               # to be inserted?
      idx_left_right = -> new_before_this, existing_a do        # #single-call
        if new_before_this
          match = match_f[ new_before_this ]
          right, idx = existing_a.each.with_index.detect { |x, _| match[ x ] }
          right or fail "node to insert before not found."
          left = 0 == idx ? nil : existing_a[ idx - 1 ]
        else
          left = existing_a.last               # nil IFF adding to empty list
          idx = existing_a.length
          right = nil
        end
        [ idx, left, right ]
      end


      normalize_proto_a = -> me, existing_a, idx do             # #single-call
        proto_a = nil
        if me._prototype
          proto_a = me._prototype._nodes.to_a
        else
          proto_a = existing_a
        end
        if proto_a.length < 2
          fail "cannot insert into a list with less than 2 items -- #{
            }for hack to work, need a prototype list, node & item."
        end

        res = [ proto_a.first, nil ] # always hold on to first, it can be spec.
        res[0] = proto_a[0]
        use_idx = [1, [idx, proto_a.length - 2].min ].max # explain this #todo
        res[1] = proto_a[ use_idx ]
        res
      end


      tail_f = -> right, proto do                               # #multi-call
        # nasty : we ned to do this before we reassign any members of "left"
        # because left itself may be the prototype node!
        #
        o = nil
        if list_getter
          if next_node[ proto ]
            fail "can't use non-ultimate node in prototype for this #{
              }hack to work." # w/o heavy hacking
          end
          o = proto.__dupe_member tail_getter
          o[list_getter] = right if right
        elsif right
          o = right
        else
          o = nil
        end
        -> _ { o }
      end



      # -- List item insertion lambdas (in ascending order of complexity)

      initial = -> me, proto_a do                               # #single-call
        # The strategy for initial insertion of an item into an empty list
        # ("list controller") is simply to use the defaults for tail_getter
        # and item_getter and for the remaining members, for those that are
        # non-nil make a dupe of the corresponding member from the prototype.
        #
        proto = proto_a.last
        res = me
        target = me
        xfer = ::Hash.new -> m do
          rs = nil
          if me[m].nil?
            rs = proto.__dupe_member m
          else
            rs = me[m]
          end
          rs
        end
        [ res, target, xfer ]
      end # (there was stark tranformation above for [#bs-010])



      insert = -> me, proto_a, left, right do                   # #single-call
        # For inserting an item under an existing parent (left) node ..

        proto = proto_a.last

        new = me.class.new
        xfer = ::Hash.new -> m do              # the strategy form making new
          rs = proto.__dupe_member m           # node elements is this
          rs
        end
                                               # `left` might itself be the
        xfer[tail_getter] = tail_f[ right, proto ] # prototype so call the
                                               # this now before you mutate it
        if list_getter
          left[tail_getter] or fail 'sanity -- expecing foo_list here'
          away = left[tail_getter][list_getter]
          if away
            fail 'sanity' if away.object_id != right.object_id
          end
          left[tail_getter][list_getter] = new

        else
          away = left[tail_getter]
          if away
            fail 'sanity' if away.object_id != right.object_id
          end
          left[tail_getter] = new

        end
        [ new, new, xfer ]
      end



      swap = -> root, proto_a, new_item, existing_length do

        # Having no `left` node means inserting at root -- b/c of the
        # structure of recursive rules this works out to be an *intense*
        # hack, see _remove!
        #
        # Specifically, (and remembering: a "node" *has* an "item"
        # (e.g. AList has AList1), the `new_node` we create actually
        # goes to live in the second slot, getting for its members
        # a lot of the members root used to have (like its item and tail)..
        # hold on tight..


        new_node = root.class.new
        proto_first = proto_a.first            # let's be clear - we use both
        proto_last = proto_a.last
                                               # When transferring each member
                                               # to the new node we created,
                                               # the default behavior is to
                                               # snatch the element from the
                                               # root and give it to the new
                                               # node, and in its stead give
                                               # root a shiny new element from
        xfer = ::Hash.new -> m do              # the prototye.
          give_to_root = proto_first.__dupe_member m
          take_from_root = root[m]
          root[m] = give_to_root
                                               # If root didn't have anything
          if ! take_from_root                  # in a spot (e.g. e0, e2), expect
            take_from_root = proto_last.__dupe_member m # that there is white-
          end                                  # -space formatting we need that
          take_from_root                       # the proto_a had but that root
        end                                    # didnt.

        original_root_tail = root[tail_getter]
        if list_getter && ! next_node[ proto_last ]
          tail = proto_last.__dupe_member tail_getter
          root[tail_getter] = tail
          tail[list_getter] = new_node         # oh sweet jesus
        else
          root[tail_getter] = new_node         # think how whacktastic this is
        end
        xfer[tail_getter] = -> _ { original_root_tail }

        original_root_item = root[item_getter]
        xfer[item_getter] = -> _ { original_root_item }

        root[item_getter] = normalize_item[ new_item, proto_last ]

        [ root, new_node, xfer ]               # [0] - result of insert call
                                               # [1] - target of transfer hash

      end



      tree_class.send :define_method, :_insert_before! do |new, new_before_this|
        existing_a = _nodes.to_a
                                               # (the `#`-marked calls below are
                                               # all #single-call, that is, they
                                               # are all only used here)

        idx, left, right = idx_left_right[ new_before_this, existing_a ]     #

        proto_a = normalize_proto_a[ self, existing_a, idx ]                 #

        if left
          res, target, xfer = insert[ self, proto_a, left, right ]           #
        elsif right
          res, target, xfer = swap[ self, proto_a, new, existing_a.length ]  #
        else
          res, target, xfer = initial[ self, proto_a ]                       #
        end

        if ! xfer.key? item_getter             # the default strategy for
          use_item = normalize_item[ new, proto_a.last ] # populating the
          xfer[item_getter] = -> _ { use_item }  # `item` (content) part of the
        end                                    # new node

        if ! xfer.key? tail_getter             # the default strategy for
          xfer[tail_getter] = tail_f[ right, proto_a.last ] # populating the
        end                                    # "next self" part        #

        self.class._members.each do |m|
          target[m] = xfer[m][ m ]
        end

        res
      end


      tree_class.send :define_method, :_items do
        _nodes.map do |node|
          node[item_getter]
        end
      end


      tree_class.send :define_method, :_nodes do
        ::Enumerator.new do |y|
          if self[item_getter] # else zero-width tree stub
            curr_node = self
            begin
              y << curr_node
              curr_node = next_node[ curr_node ]
            end while curr_node
          end
          nil
        end
      end



      tree_class.send :define_method, :_remove! do |search_item|

        parent = res = nil

        match = match_f[ search_item ]
        target = _nodes.detect do |node|
          rs = match[ node ] || nil
          if ! rs
            parent = node
          end
          rs
        end

        fail "node to remove not found." if ! target

        if parent
          parent[tail_getter] = target[tail_getter]
          target[tail_getter] = nil
          res = target
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

          fail 'sanity' if object_id != target.object_id
          source = next_node[ target ] || target.class.new
          fail 'sanity' if source.class != target.class
          xfer = ::Hash.new -> m { target[m] }
          xfer[tail_getter] = -> _ { nil }
          target.class._members.each do |m|
            swap_me = source[m]
            source[m] = xfer[m][ m ]
            target[m] = swap_me
          end
          res = source # this is the sketchy thing! it is a "surrogate angel"
        end
        res
      end



      define_items_method tree_class, stem


      nil
    end
  end


  module Sexp::Auto::Hacks::RecursiveRule::SexpInstanceMethods

    def _append! new
      _insert_before! new, nil
    end

    def list?
      true
    end

    attr_accessor :_prototype     # used in eponymous file

  end
end
