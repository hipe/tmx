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
      if i.has_members_of_interest
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


    methods = [:_append!, :_insert_item_before_item, :_items, :_remove!]

    methods.push :_named_prototypes # this is *so* sketchy here #experimental
                                  # but still we want in the check below
                                  # to make sure we aren't overriding the
                                  # good methods

    define_singleton_method :enhance do |i, stem, item, tail, list=nil|
                                  # *NOTE* the above 3 parameters `item`,
                                  # `tail`, `list` are *all* symbols that
                                  # represent struct member names (rule names)
                                  # from the grammar!

      # #experimental'y functional - everything is here
      tree_class = i.tree_class

      (methods & tree_class.instance_methods).empty? or fail 'sanity'
                                               # be sure we're not overwriting

      item = item.intern          # normalize every actual param
      list = list.intern if list
      stem = stem.intern
      tail = tail.intern



      tree_class._hacks.push :RecursiveRule    # #debugging-feature-only
      tree_class.send :include,
                          Sexp::Auto::Hacks::RecursiveRule::SexpInstanceMethods

      match_p = -> search_item do              # a function to make matcher
        if ::String === search_item            # functions for matching nodes
          -> node { search_item == node[item] }  # that new nodes are
        else                                   # supposed to come before / after
          -> node { search_item.object_id == node[item].object_id }
        end
      end

      next_node = if list then                # determining what is the next
        -> node do                            # node after a node is different
          o = node[ tail ]                    # based on whether or not there
          o && o[ list ]                      # is a tail getter
        end
      else
        -> node { node[tail] }
      end


      # -- Item insertion lambdas

      normalize_item = -> item_elem, proto do  # normalize the item for insert
        res = nil                              # (parsing string if necessary)
        begin
          if ! (::String === item_elem)        # then item is presumably a sexp
            break( res = item_elem )           # and validating it would be
          end                                  # prohibitively annoying
          o = proto[ item ]
          if ::String === o                    # the elem in the proto is also
            break( res = item_elem )           # a string, they both are, so
          end                                  # again validating is meh

          # item is string and proto elem is not string, assume we are to parse
          res = o.class.parse o.class.rule, item_elem, -> failed_parser do
            fail "failed to parse item to insert - #{
              }#{ ( failed_parser.failure_reason || item_elem ).inspect }"
          end

        end while nil
        res
      end
                                               # what is the index, the left
                                               # and right node of the new node
                                               # to be inserted?
      idx_left_right = -> new_before_this, existing_a do        # #single-call
        if new_before_this
          match = match_p[ new_before_this ]
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


      tail_p = -> right, proto do                               # #multi-call
        # nasty : we ned to do this before we reassign any members of "left"
        # because left itself may be the prototype node!
        #
        o = nil
        if list
          if next_node[ proto ]
            fail "can't use non-ultimate node in prototype for this #{
              }hack to work." # w/o heavy hacking
          end
          o = proto.__dupe_member tail
          o[list] = right if right
        elsif right
          o = right
        else
          o = nil
        end
        -> _ { o }
      end



      # -- List item insertion lambdas (in ascending order of complexity)

                                  # #experimental for hacks .. what is the list
                                  # of separator or whitespace-like elements
                                  # that is true-ish in both the head and tail
                                  # prototypes?
      inner_p = -> me, proto_0, proto_n do # experimental for hacks!
        ( me.class._members - [ item, tail ] ).reduce( [] ) do |memo, m|
          if proto_0[m] && proto_n[m]
            memo << m
          end
          memo
        end # e.g. `e0`, `e2`, `sep`
      end

      initial = -> me, proto_a do                               # #single-call
        # This is for the case of initial insertion of an item into an empty
        # list node -- something that is not normally possibly with recursive
        # rules of the form  foo_list ::= (foo (sep foo_list)? sep?)?
        # (whenever a list node is created it has something in it),
        # so this only used for the kind of weird hacks this library
        # is for..
        #
        # Regardless, the strategy for the insertion of an item into an empty
        # list (which we might call a "list controller") is as follows:
        #
        # Take for example a prototype "a=b, c=d":
        # In this case, we want the newly inserted item to look like "e=f",
        # so note neither the "," (which is `e2` of proto_0 in one grammar)
        # nor the " " (which is `e0` of proto_n in the same), make in into
        # the final item (er, list node). So we have bit of a problem inferring
        # how the first element inserted into a list should look given
        # that the the prototype is necessarily (and reasonably) at least
        # two elements long.
        #
        # What we do for now is say, "we will take from proto_0 the element


        proto_0, proto_n = [ proto_a.first, proto_a.last ]

        inner = inner_p[ me, proto_0, proto_n ] # see

        xfer = ::Hash.new -> m do
          if me[m]                # if there was already *anything* there, just
            me[m]                 # use that, don't clobber it.
          elsif inner.include? m
            rs = proto_0.__dupe_member m
          end
          rs
        end
        [ me, me, xfer ]          # `me` is the final result, and receiver
                                  # (below line left intact for that project.)
      end # (there was stark tranformation above for [#bs-010])




      insert = if list
        # For inserting an item under an existing parent (left) node ..
        -> me, proto_a, left, right do
          proto_0, proto_n = [proto_a.first, proto_a.last]

          new = proto_n.__dupe except:[item, [tail, list]]

          if ! left[tail]
            left[tail] = proto_0[tail].__dupe except: [list]
          end
          left[tail][list] = new

                                               # (ick) b/c everything is done
          selfsame = -> k { new[k] }           # above we just xfer in the same
          xfer = ::Hash.new selfsame           # values here..
          xfer[tail] = selfsame                # and here.

          if right
            new[tail][list] = right
          end
          [new, new, xfer]
        end
      else
        -> me, proto_a, left, right do
          proto_0, proto_n = [proto_a.first, proto_a.last]

          ancillary = me.class._members - [item, tail]   # `e0`, `e2`
          if ! right
            ancillary.each do |m|
              if ! left[m] and proto_0[m]
                left[m] = proto_0.__dupe_member m        # e.g. ','
              end
            end
          end

          if right
            new = proto_n.class.new
            ancillary.each do |m|                        # leading ' ' and
              if proto_0[m]                              # trailing ','
                new[m] = proto_0.__dupe_member m
              elsif proto_n[m]
                new[m] = proto_n.__dupe_member m
              end
            end
          else
            new = proto_n.__dupe except:[item, tail]     # e.g. ' '
          end

          selfsame = -> k { new[k] }
          xfer = ::Hash.new selfsame
          xfer[tail] = selfsame

          if right
            new[tail] = right
          end

          left[tail] = new

          [new, new, xfer]
        end
      end



      swap = -> root, proto_a, new_item, existing_length do

        # Having no `left` node means inserting at root -- b/c of the
        # structure of recursive rules this works out to be an *intense*
        # hack, see _remove!
        #
        # Specifically, (and remembering: a "node" *has* an "item"
        # (e.g. AList has AList1), the `new_list` we create actually
        # goes to live in the second slot, getting for its members
        # a lot of the members root used to have (like its item and tail)..
        # hold on tight..


        proto_0, proto_n = [proto_a.first, proto_a.last]
        new_list = root.class.new

                                               # When transferring each member
                                               # to the new node we created,
                                               # the default behavior is to
                                               # snatch the element from the
                                               # root and give it to the new
                                               # node, and in its stead give
                                               # root a shiny new element from
        xfer = ::Hash.new -> m do              # the prototye.
          give_to_root = proto_0.__dupe_member m
          take_from_root = root[m]
          root[m] = give_to_root
                                               # If root didn't have anything
          if ! take_from_root                  # in a spot (e.g. e0, e2), expect
            take_from_root = proto_n.__dupe_member m # that there is white-
          end                                  # -space formatting we need that
          take_from_root                       # the proto_a had but that root
        end                                    # didnt.

        orig_root_tail = root[tail]            # about to get clobbered
        if list && ! next_node[ proto_n ]
          tail_shell = proto_0[tail].__dupe except: [list]
          tail_shell[list] = new_list
          root[tail] = tail_shell              # clobbered is in orig_root_tail
        else
          root[tail] = new_list                # clobbered is in orig_root_tail
        end
        xfer[tail] = -> _ { orig_root_tail }

        original_root_item = root[item]
        xfer[item] = -> _ { original_root_item }

        root[item] = normalize_item[ new_item, proto_n ]

        [ root, new_list, xfer ]               # [0] - result of insert call
                                               # [1] - target of transfer hash

      end



      tree_class.send :define_method, :_insert_item_before_item do |new, new_before_this|
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

        if ! xfer.key? item                    # the default strategy for
          use_item = normalize_item[ new, proto_a.last ] # populating the
          xfer[item] = -> _ { use_item }       # `item` (content) part of the
        end                                    # new node

        if ! xfer.key? tail                    # the default strategy for
          xfer[tail] = tail_p[ right, proto_a.last ] # populating the
        end                                    # "next self" part        #

        self.class._members.each do |m|
          target[m] = xfer[m][ m ]
        end

        res
      end


      tree_class.send :define_method, :_items do
        _nodes.map do |node|
          node[item]
        end
      end


      tree_class.send :define_method, :_items_count_exceeds do |count|
        !! _nodes.each_with_index.detect { |_, idx| idx == count }
      end


      tree_class.send :define_method, :_nodes do  # #open [#085]
        ::Enumerator.new do |y|
          if self[item] # else zero-width tree stub
            curr_node = self
            begin
              y << curr_node
              curr_node = next_node[ curr_node ]
            end while curr_node
          end
          nil
        end
      end


      tree_class.send :define_method, :to_scan do
        subsequent_p = nil
        p = -> do
          if self[ item ]  # else zero-width tree stub
            x = self
            p = subsequent_p[ x ]
          else
            p = EMPTY_P_
          end
          x
        end
        subsequent_p = -> x do
          -> do
            x = next_node[ x ]
            x or p = EMPTY_P_
            x
          end
        end
        Callback_.scan do
          p[]
        end
      end



      tree_class.send :define_method, :_remove! do |search_item|

        parent = res = nil

        match = match_p[ search_item ]
        target = _nodes.detect do |node|
          rs = match[ node ] || nil
          if ! rs
            parent = node
          end
          rs
        end

        fail "node to remove not found." if ! target

        if parent
          parent[tail] = target[tail]
          target[tail] = nil
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
          xfer[tail] = -> _ { nil }
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
      _insert_item_before_item new, nil
    end

    def list?
      true
    end

    def _named_prototypes         # this is an aggregious bit of cross-hack
                                  # dependency - assume that this sexp class
                                  # wants to take part in the prototype romp and
                                  # assume furthermore that we will end up
                                  # further down in the ancestor chain than the
    end                           # module that has the correct definition
                                  # for this, should actual prototypes exist!
                                  # the falseish-ness of this is then used to
                                  # emit `No_Prototypes` events.

    attr_accessor :_prototype     # used in eponymous file, see above comment.

  end
end
