module Skylab::Basic

  class Digraph  # see [#025]

    # relevant: http://en.wikipedia.org/wiki/Tree_(data_structure)

    class << self

      def node_class
        Node__
      end
    end

  class Node__

    class << self

      def bound g, i
        Node__::Bound__.new g, i
      end
    end

    def initialize nln
      @has_associations = nil
      @normalized_local_node_name = nln
    end

    # ~ :+[#mh-021] a typical base class implementation:
    def dupe
      dup
    end
    def initialize_copy otr
      init_copy( * otr.get_args_for_copy ) ; nil
    end
  protected
    def get_args_for_copy
      [ @normalized_local_node_name, ( @associations if @has_associations ) ]
    end
  private
    def init_copy normalized_local_node_name, associations
      @normalized_local_node_name = normalized_local_node_name
      @has_associations = if associations
        @associations = associations.dup
        true
      else
        false
      end ; nil
    end
    # ~

  public

    def absorb_association name_i
      @has_associations ||= true
      @associations ||= Callback_::Box.new
      @associations.touch name_i do true end
      nil
    end

    def direct_association_targets_include name_i
      @has_associations and @associations.has_name name_i
    end

    def direct_association_target_names
      @has_associations and @associations.get_names
    end

    def has_association_to name_i
      @has_associations and @associations.has_name name_i
    end

    attr_reader :normalized_local_node_name

    Autoloader_[ self ]
  end

    def self.[] *a
      g = new
      g.absorb_nodes a
      g
    end

    def initialize
      @a = [] ; @h = {}  # #open [#033]
      @node_class ||= Basic_::Digraph.node_class
    end

    # ~ :+[#mh-021] typical base class implementation:
    def dupe
      dup
    end
    def initialize_copy otr
      init_copy( * otr.get_args_for_copy ) ; nil
    end
  protected
    def get_args_for_copy
      [ @a, @h, @node_class ]
    end
  private
    def init_copy order, hash, node_class
      @a = order.dup ; h = { }
      hash.each_pair do |k, v|
        h[ k ] = v.dupe
      end
      @h = h
      @node_class = node_class ; nil
    end
    # ~

  public

    # ~ non-mutating (i.e inspection & retrieval)

    def length
      @a.length
    end

    def describe_digraph * x_a
      Basic_::Digraph::Describe__.new( self, x_a ).execute
    end

    def fetch name_i, &b
      @h.fetch name_i, &b
    end

    def has? name_i
      @h.key? name_i
    end

    def x_is_kind_of_y x, y
      walk_from_d_x_to_y_detect_equal_key 0, x, y
    end

    def indirect_association_targets_include source, target
      walk_from_d_x_to_y_detect_equal_key 2, source, target
    end

    def walk_from_d_x_to_y_detect_equal_key d, x, y
      !! walk_pre_order( x, d ).detect( & y.method( :== ) )
    end ; private :walk_from_d_x_to_y_detect_equal_key

    def names
      @a.dup
    end

    def node_count
      @a.length
    end

    # ~ tree-walking enumerators

                                  # 0 = you are paul erdos, include self..
    def walk_pre_order start, min_level, seen_h=nil
      if ! seen_h || ! seen_h[ start ]
        ::Enumerator.new do |y|
          seen_h ||= {  }
          visit = -> curr_level, name_i do
            cx = fetch( name_i ).direct_association_target_names
            seen_h[ name_i ] = true
            y << name_i if curr_level >= min_level
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

    # ~ operations that produce new graphs

    def invert  # #storypoint-35
      order = [ ] ; assoc = { }
      st = to_node_edge_stream_
      edge = st.gets
      while edge
        source, target = edge.to_a
        if target
          assoc.fetch target do
            order << target
            assoc[target] = []
          end.push source
        else
          assoc[ source ] = nil  # this will bork above unless callee is sound
          order << source  # ! (just like original)
        end
        edge = st.gets
      end
      _build order, assoc
    end

    def minus name_a  # #storypoint-45
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
      @a.each do |key|
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

    # ~ mutators

    def node! name_i, predicate_h=nil  # #storypoint-55
      absrb_nd name_i, predicate_h
      bnd_h.fetch name_i do |k|
        @bnd_h[ k ] = Node__.bound self, k
      end
    end
  private
    def absrb_nd name_i, pred_h
      if pred_h
        target_a = Predicate__.new( pred_h ).target_a
        do_absorb = true
      elsif ! @h.key? name_i
        do_absorb = true
      end
      do_absorb and absorb_node name_i, target_a, nil ; nil
    end

    class Predicate__
      def initialize h
        @target_a = nil
        h.each do |k, v|
          send :"#{ k }=", v
        end ; nil
      end
      attr_reader :target_a
    private
      def is= x
        @target_a = ::Array.try_convert( x ) || [ x ] ; nil
      end
    end

    def bnd_h
      @bnd_h ||= {}
    end
  public

    def absorb_nodes x_a, accum=nil  # #storypoint-65
      idx = 0 ; len = x_a.length
      aa = [ ]
      while idx < len && ::Symbol === x_a[ idx ]
        aa << [ x_a[ idx ], nil ]
        idx += 1
      end
      if idx < len && ::Hash === x_a[ idx ]
        x_a[ idx ].each do |k, v|
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
        idx += 1
      end
      if idx < len
        raise ::ArgumentError, "no - #{ x_a[ idx ].class }"
      else
        acum = ::Enumerator::Yielder.new(& accum ) if accum
        aa.each do |aaa|
          absorb_node(* aaa, acum )
        end
      end
      nil  # important - do not give callers the wrong idea
    end

    def absorb_node name_i, target_a=nil, accum=nil  # #storypoint-75
      if ! @h.key? name_i
        node = @node_class.new name_i
        @a.push name_i
        @h[ name_i ] = node
        accum and accum << name_i
      end
      if target_a
        target_a.each do |tsym|
          absorb_node( tsym, nil, accum ) if ! @h.key? tsym
          @h[ name_i ].absorb_association tsym
        end
      end ; nil
    end

    def clear  # #storypoint-85
      @h.clear ; @a.clear ; nil
    end

    def to_node_edge_stream_  # #storypoint-95

      p = -> do
        source_a = []
        target_a = []
        targeted_h = {}
        orphan_a = []

        @a.each do | k |
          node = @h.fetch k
          cx = node.direct_association_target_names
          if cx and cx.length.nonzero?
            cx.each do | k_ |
              source_a.push k
              target_a.push k_
              targeted_h[ k_ ] = true
            end
          else
            orphan_a.push source_a.length
            source_a.push k
            target_a.push nil
          end
        end

        index = orphan_a.pop
        while index
          if targeted_h[ source_a[ index ] ]
            source_a[ index, 1 ] = EMPTY_A_
            target_a[ index, 1 ] = EMPTY_A_
          end
          index = orphan_a.pop
        end

        num_times = source_a.length
        d = -1; last = num_times - 1
        p = -> do
          if d < last
            d += 1
            Edge___.new source_a[ d ], target_a[ d ]
          end
        end
        p[]
      end

      Callback_.stream do
        p[]
      end
    end

    Edge___ = ::Struct.new :source_symbol, :target_symbol

  private

    def _build order, assoc
      new = self.class.new
      new.instance_exec do
        order.each do |key|
          absorb_node key, assoc.fetch( key ), nil
        end
      end
      new
    end

  public

    def _a
      @a
    end
  end
end
