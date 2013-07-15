module Skylab::Semantic

  class Semantic::Digraph  # (reopens below)
    # relevant: http://en.wikipedia.org/wiki/Tree_(data_structure)
  end

  class Semantic::Digraph::Node  # (#stowaway)

    extend MetaHell::Autoloader::Autovivifying::Recursive

    def absorb_association sym
      @associations ||= MetaHell::Formal::Box::Open.new
      if ! @associations.has? sym
        @associations.add sym, true
      end
      nil
    end

    def direct_association_targets_include sym
      if associations
        @associations.has? sym
      end
    end

    def direct_association_target_names
      if associations
        @associations.names
      end
    end

    def dupe
      ba = base_args
      self.class.allocate.instance_exec do
        base_init(* ba )
        self
      end
    end

    def has_association_to sym
      if associations
        @associations.has? sym
      end
    end

    attr_reader :normalized_local_node_name

  protected

    def initialize nln
      @normalized_local_node_name = nln
    end

    #         ~ dupe support ~

    def base_args
      [ @normalized_local_node_name, associations ]
    end

    def base_init normalized_local_node_name, associations
      @normalized_local_node_name = normalized_local_node_name
      if associations
        @associations = associations.send :dupe
      end
      nil
    end

    # --*--

    attr_reader :associations  # not public (it's an open box)

  end

  class Semantic::Digraph  # #todo - don't you wish you were a box!?

    def self.[] *a                # convenience constructor
      g = new
      g.absorb_nodes a
      g
    end

    # --*--

    #         ~ non-mutating (i.e inspection & retrieval) ~

    def length
      @order.length
    end

    # used for debugging and some elsewhere hacks..
    def describe to=nil, tight=false
      io = if to then to else
        Services::StringIO.new
      end
      seen = false  # (write the newlines at the beginning not end for reasons)
      line = -> x do
        io.write "#{ "\n" if seen }#{ x }"
        seen ||= true
      end
      if ! tight
        tgt_solo_h = ::Hash.new do |h, k|  # #todo remove post integration
          line[ k ]
          h[k] = true
        end
      end
      sep = tight ? '->' : ' -> '
      associations.each do |source_sym, target_sym|
        tgt_solo_h[ target_sym ] if target_sym && ! tight
        line[ "#{ source_sym }#{ "#{ sep }#{ target_sym }" if target_sym }" ]
      end
      if ! seen  # i don't love this, but you could always check `node_count`
        line[ "# (empty)" ]
      end
      if ! to
        io.rewind
        io.read
      end
    end

    def describ  # #todo after intergration
      describe nil, true
    end

    def fetch sym, &b
      @hash.fetch sym, &b
    end

    def has? sym
      @hash.key? sym
    end

    def indirect_association_targets_include source, target
      !! walk_pre_order( source, 2 ).detect { |s| target == s }
    end

    def names
      @order.dup
    end

    def node_count
      @order.length
    end

    #         ~ tree-walking enumerators ~

                                  # 0 = you are paul erdos, include self..
    def walk_pre_order start, min_level, seen_h=nil
      if ! seen_h || ! seen_h[ start ]
        ::Enumerator.new do |y|
          seen_h ||= {  }
          visit = -> curr_level, sym do
            cx = fetch( sym ).direct_association_target_names
            seen_h[ sym ] = true
            y << sym if curr_level >= min_level
            if cx
              cx.each do |sm|
                seen_h.fetch sm do
                  visit[ curr_level + 1, sm ]
                end
              end
            end
          end
          visit[ 0, start ]
          nil
        end
      end
    end

    def walk_post_order start, seen_h=nil
      if ! seen_h || ! seen_h[ start ]
        ::Enumerator.new do |y|
          seen_h ||= {  }
          visit = -> sym do
            cx = fetch( sym ).direct_association_target_names
            seen_h[ sym ] = true  # etc
            if cx
              cx.each do |sm|
                seen_h.fetch sm do
                  visit[ sm ]
                end
              end
            end
            y << sym
          end
          visit[ start ]
          nil
        end
      end
    end

    #         ~ operations that produce new graphs ~

    def dupe
      ba = base_args
      self.class.allocate.instance_exec do
        base_init(* ba )
        self
      end
    end

    # `invert` - produce a new graph with the same members and the same
    # associations but all the directions reversed.

    def invert
      # (in one pass accumulate the associations per node, in a second
      # pass blit them to the new graph)
      order = [ ] ; assoc = { }
      associations.each do |source, target|
        if target
          assoc.fetch target do
            order << target
            assoc[target] = []
          end.push source
        else
          assoc[ source ] = nil  # this will bork above unless callee is sound
          order << source  # ! (just like original)
        end
      end
      _build order, assoc
    end

    # `minus` - create a new subset graph whose members consist of all the
    # members whose names do not appear on the list `name_a`, nor point
    # (directly or indirectly) to any of the nodes whose names appear on
    # the list.

    def minus name_a
      # make a  'black hash' - what are all the nodes you can touch following
      # the is-a relationships (from parent to child this time) from the list?
      extent_h = { }
      inverted = invert
      name_a.each do |key|
        if inverted.has? key
          if ! extent_h[ key ]
            inverted.walk_pre_order( key, 0, extent_h ).each do end
              # see each one
          end
        end
      end
      # build a sub-graph wherein you don't include any nodes on the list
      order = [ ] ; assoc = { }
      @order.each do |key|
        if ! extent_h[ key ]
          node = fetch key
          aa = nil
          cx = node.direct_association_target_names
          if cx
            cx.each do |k|
              if ! extent_h[ k ]
                ( aa ||= [ ] ) << k
              end
            end
          end
          order << key
          assoc[ key ] = aa
        end
      end
      _build order, assoc
    end

    #         ~ mutators ~

    # `node!` - experimental monadic node merger/getter that results
    # in a (controller-like) "bound" node
    # (with experimental old-school predicate (`is`) syntax)
    # (it is a smell to toss our internal node structure around externally)

    def node! name, predicate_h=nil
      do_absorb = if predicate_h
        target_a = nil
        pred_h_h = {
          is: -> v { target_a = ( ::Array === v ) ? v : [ v ] }
        }
        predicate_h.each do |k, v|
          pred_h_h.fetch( k )[ v ]
        end
        true
      elsif ! @hash.key? name
        true
      end
      absorb_node name, target_a, nil if do_absorb
      @node_controller_h ||= { }
      @node_controller_h.fetch name do |k|
        @node_controller_h[ k ] =
          Semantic::Digraph::Node::Bound.new( self, k )
      end
    end

    # `absorb_nodes` - the high level dsl-ish entrypoint for creating a graph.
    # "absorbs" [ symbol [..]] [ hash ], creating (where necessary) a node
    # in the graph with one such normalized name for each symbol, and for
    # each key-value pair in any provided final hash, creates where necessary
    # a node with one such normalized name for each key *and* another
    # node for each value, and if necessary an association from the former
    # to the latter. (oh the values can be arrays themselves, a flat list
    # of symbols that etc.) (it makes a lot more sense when you see the input
    # data.)
    #
    # `accum` if provided will be called with, for each new node that is
    # created in the process of this absorption, one *symbol* name of the node.

    def absorb_nodes a, accum=nil
      i = 0
      len = a.length
      aa = [ ]
      while i < len && ::Symbol === a[i]
        aa << [ a[i], nil ]
        i += 1
      end
      if i < len && ::Hash === a[i]
        a[i].each do |k, v|
          if ::Symbol === k
            case v
            when ::Symbol
              aa << [ k, [ v ] ]
            when ::Array
              aa << [ k, v.map do |x|
                ::Symbol === x or raise ::ArgumentError, "no: #{ x }"
                x
              end ]
            else
              raise ::ArgumentError, "no: #{ v }"
            end
          else
            raise ::ArgumentError, "no - #{ k.inspect }"
          end
        end
        i += 1
      end
      if i < len
        raise ::ArgumentError, "no - #{ a[i].class }"
      else
        acum = ::Enumerator::Yielder.new(& accum ) if accum
        aa.each do |aaa|
          absorb_node(* aaa, acum )
        end
      end
      nil  # important - do not give callers the wrong idea
    end

    def nodes! x  # #todo remove post integration
      sym_a = [ ]
      absorb_nodes x, -> sym { sym_a << sym }
      sym_a
    end

    # `flatten` - NOTE #todo remove post integration
    # result is an enumerator (ary actually) that yields, for each node named in
    # `nodes`, each of its `is-a` parents and then then node itself.
    # Each node is presented only once, so nodes that have been presented
    # already are skipped on subsequent visits.  #todo: find out why this is
    # useful to have this not be recursive.  It may not be.

    def flatten sym_a  # #todo remove post integration
      seen_h = { }
      res_a = [ ]
      sym_a.each do |sym|
        ea = walk_post_order sym, seen_h
        if ea
          ea.each do |sm|
            res_a << sm
          end
        end
      end
      res_a
    end

    -> do  # `[]`  #todo remove after integration
      empty_a = [ ].freeze  # ocd
      NodePxy = MetaHell::Proxy::Nice.new :all_ancestor_names,
        :local_normal_name, :respond_to?, :is?, :is_names
      rt_h = { type: false, payload: false }
      define_method :[] do |sym|
        if @hash.key? sym
          ( @ghetto_h ||= { } ).fetch sym do
            pxy = NodePxy.new(
              all_ancestor_names: -> do
                walk_pre_order( sym, 0 ).map { |sm| sm }
              end,
              local_normal_name: -> { sym },
              respond_to?: -> x { rt_h.fetch x },
              is?: -> sm do
                if sym == sm then true
                else
                  if @hash.fetch( sym ).direct_association_targets_include sm
                    true
                  else
                    indirect_association_targets_include sym, sm
                  end
                end
              end,
              is_names: -> do
                @hash.fetch( sym ).direct_association_target_names || empty_a
              end
            )
            @ghetto_h[ sym ] = pxy
          end
        end
      end
    end.call

    alias_method :nodes_count, :node_count # #todo remove after integration

    # `absorb_node` - merge in a normalized_local_node_name of a node
    # and zero or more target associaiton names. `accum` if provided
    # will be yeilded (with '<<') each symbolc name that is added
    # to the graph as a result of this operation.

    def absorb_node sym, target_a=nil, accum=nil
      if ! @hash.key? sym
        node = @node_class.new sym
        @order << sym
        @hash[ sym ] = node
        accum << sym if accum
      end
      if target_a
        target_a.each do |tsym|
          absorb_node( tsym, nil, accum ) if ! @hash.key? tsym
          @hash[ sym ].absorb_association tsym
        end
      end
      nil
    end

    # `clear` - from the graph's perspective, remove all nodes.  doesn't
    # do anything to the nodes themselves. Should be same as constructing
    # a new graph.

    def clear
      @hash.clear
      @order.clear
      nil
    end

  protected

    def initialize
      @order = [ ]
      @hash = { }
      @node_class ||= Semantic::Digraph::Node
    end

    #         ~ dupe support ~

    def base_args
      [ @order, @hash, @node_class ]
    end

    def base_init order, hash, node_class
      @order = order.dup
      @hash = { }
      hash.each do |k, v|
        @hash[ k ] = v.dupe
      end
      @node_class = node_class
      nil
    end

    # `associations` - result is an enumerator that represently the graph
    # "flatly" as a series associations.
    # Each yield of the enumerator will have 2 values: the association's source
    # and target symbols (in that order). The order that the associations will
    # arrive in is based on the order of the datastructure, not e.g a pre-order
    # walk (so just a loop inside a loop, not recursive).
    # (This method is protected in part because we anticipate possibly having
    # named associations one day, in which case we might want e.g 3 params!?)
    # Also (and perhaps strangely), for orphan nodes that both have no
    # outgoing associations of their own and are not pointed to by an
    # association, they will each also have representation in this enumeration,
    # presented as a yield with the second element being nil.
    # For now we expend memory in order to present orphans in their original
    # order with respect to non-orphan nodes, but this may change.

    empty_a = [ ].freeze

    define_method :associations do
      ::Enumerator.new do |y|
        source_a = [] ; target_a = [] ; targeted_h = { } ; orphan_a = []
        @order.each do |key|
          node = @hash.fetch key
          cx = node.direct_association_target_names
          if cx and cx.length.nonzero?
            cx.each do |k|
              source_a << key
              target_a << k
              targeted_h[k] = true
            end
          else
            orphan_a << source_a.length
            source_a << key
            target_a << nil
          end
        end
        while index = orphan_a.pop
          if targeted_h[ source_a[ index ] ]
            source_a[ index, 1 ] = empty_a
            target_a[ index, 1 ] = empty_a
          end
        end
        ( 0 ... source_a.length ).each do |idx|
          y.yield source_a[ idx ], target_a[ idx ]
        end
        nil
      end
    end

    def _build order, assoc
      new = self.class.new
      new.instance_exec do
        order.each do |key|
          absorb_node key, assoc.fetch( key ), nil
        end
      end
      new
    end
  end
end
