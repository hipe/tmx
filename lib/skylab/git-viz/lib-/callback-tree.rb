module Skylab::GitViz

  module Lib_

    class Callback_Tree  # read [#033] the different kinds of callback trees

      def initialize hash, identifier_x = self.class

        @identifier_x = identifier_x
        p = -> h do
          h.keys.each do |k|
            x = h[ k ]
            cls = NODE_CLASS_H__[ x ]
            h[ k ] = if cls
              cls.new
            else
              p[ x ]
              Branch__.new x
            end
          end
        end
        p[ hash ]
        @root = Branch__.new hash
      end

      class Listeners_Leaf__
        def initialize
          @p_a = nil
        end
        attr_reader :p_a
        def add_p p
          ( @p_a ||= [] ) << p ; nil
        end
        def retrieve_child i
          raise ::KeyError, "off the end: '#{ i }'"
        end
      end

      class Handler_Leaf__
        def initialize
          @p = nil
        end
        attr_accessor :p
        def to_handler_pair
          [ nil, @p ]
        end
      end

      class Shorters_Leaf__
        def initialize
          @callback_x_a = nil
        end
        attr_reader :callback_x_a
        def add_cb_x x
          ( @callback_x_a ||= [] ) << x ; nil
        end
      end

      NODE_CLASS_H__ = {
        handler: Handler_Leaf__,
        listeners: Listeners_Leaf__,
        shorters: Shorters_Leaf__
      }.freeze

      class Branch__
        def initialize h
          @h = h ; @p = @p_a = nil
        end
        attr_reader :h, :p_a
        attr_accessor :p
        def add_p p
          ( @p_a ||= [] ) << p ; nil
        end
        def to_handler_pair
          [ @h, @p ]
        end
        def retrieve_child i
          @h.fetch i
        end
      end

      Node__ = ::Struct.new :h, :p

      def add_listener * i_a, p
        node = rslv_some_node i_a
        node.add_p p ; nil
      end

      def set_handler * i_a, p
        node = rslv_some_node i_a
        node.p and raise ::KeyError, "won't clobber exiting '#{ i_a.last }'"
        node.p = p ; nil
      end

      def add_callback * i_a, x
        node = rslv_some_node i_a
        node.add_cb_x x ; nil
      end

    private
      def rslv_some_node i_a
        ( 0 ... i_a.length ).reduce @root do |m, d|
          k = i_a.fetch d
          m.h.fetch k do
            raise ::KeyError, say_no_such_channel( d, i_a )
          end
        end
      end
    public

      def call_listeners * i_a, & p
        value_p = -> do
          r = p[] ; value_p = -> { r } ; r
        end
        stack_p_a_a = nil
        add_p_a = -> p_a do
         ( stack_p_a_a ||= [] ) << p_a
        end
        leaf = i_a.reduce @root do |node, i|
          p_a = node.p_a and add_p_a[ p_a ]
          node.retrieve_child i
        end
        p_a = leaf.p_a and add_p_a[ p_a ]
        if stack_p_a_a
          stack_p_a_a.each do |p_a_|
            p_a_.each do |p_|
              p_[ value_p[] ]
            end
          end ; nil
        end
      end

      def call_handler * i_a, & p
        exception = i_a.pop
        largest_d = last_seen_p = nil
        last = i_a.length
        ( 0 .. last ).reduce @root do |m, d|
          largest_d = d
          h_, p_ = m.to_handler_pair
          p_ and last_seen_p = p_
          h_ or break
          last == d and break
          k = i_a.fetch d
          _m_ = h_.fetch k do
            raise ::KeyError, say_no_such_channel( d, i_a )
          end
          _m_ or break
        end
        ( last_seen_p || p || ::Kernel.method( :raise ) )[ exception ]
      end

      def call_attempters_with_map * i_a, p  # [#033]:#the-attempters-pattern
        did_succeed = false
        x_a = rslv_any_shorters_leaf_callback_x_a i_a
        x_a and x_a.each do |x|
          did_succeed = p[ x ]
          did_succeed and break
        end
        did_succeed
      end

      def call_shorters_with_map * i_a, p  # see [#033]:#the-shorters-pattern
        ec = PROCEDE_
        x_a = rslv_any_shorters_leaf_callback_x_a i_a
        x_a and x_a.each do |x|
          ec = p[ x ]
          ec and break
        end
        ec
      end

      def aggregate_any_shorts_with_map * i_a, p
        y = PROCEDE_
        x_a = rslv_any_shorters_leaf_callback_x_a i_a
        x_a and x_a.each do |x|
          ec = p[ x ]
          ec or next
          ( y ||= [] ) << [ x, ec ]
        end
        y
      end

      def rslv_any_shorters_leaf_callback_x_a i_a
        rslv_some_shorters_leaf( i_a ).callback_x_a
      end

      def rslv_some_shorters_leaf i_a
        i_a.length.times.reduce @root do |m, d|
          m.h.fetch i_a.fetch( d ) do
            raise ::KeyError, say_no_such_channel( d, i_a )
          end
        end
      end

      def say_no_such_channel d, a
        bad_k = a.fetch d ; any_good_k_a = a[ 0, d ]
        node = any_good_k_a.reduce @root do |m, k|
          m.h.fetch k
        end
        trunk_s_a = any_good_k_a.map { |i| "#{ i }" }
        branch_s_a = node.h.keys.map { |i| "'#{ i }'" }
        article_adjective, verb, s = if 1 == branch_s_a.length
          [ 'the only ', 'is' ] else
          [ nil, 'are', 's' ] end
        _moniker = trunk_s_a.length.zero? ? 'root' : ( trunk_s_a * ' ' )
        "there is no '#{ bad_k }' channel #{
         }at the '#{ _moniker }' node. #{
          }#{ article_adjective }known channel#{ s } #{ verb } #{
           }#{ Oxford[ ', ', '[none]', ' and ', branch_s_a ] }#{
            } (for the #{ @identifier_x } callbacks)"
      end

      def glom other
        p = -> me, otr do
          p_ = otr.p and me.p = p_
          h = me.h ; h_ = otr.h
          h && h_ and h.each_pair do |i, me_|
            otr_ = h_[ i ]
            if otr_
              p[ me_, otr_ ]
            end
          end
        end
        p[ @root, other.root ] ; nil
      end
    protected
      attr_reader :root

      class Mutable_Specification
        def initialize
          @h = { }
        end
        def << i
          @h[ i ] = :shorters ; self
        end
        def flush
          h = @h ; @h = nil
          Specified_Callback_Tree_.new h
        end
      end

      class Specified_Callback_Tree_ < self
        class << self
          alias_method :orig_new, :new
          def new h
            ::Class.new( self ).class_exec do
              class << self ; alias_method :new, :orig_new ; end
              const_set :H__, h.freeze
              self
            end
          end
        end

        def initialize identifier_x=self.class
          super DEEP_DUP_H__[ self.class::H__ ], identifier_x
        end
        DEEP_DUP_H__ = -> h do
          h_ = {}
          h.each_pair do |k, x|
            ::Hash.try_convert( x ) and x = DEEP_DUP_H__[ x ]
            h_[ k ] = x
          end
          h_
        end
      end

      PROCEDE_ = nil
    end
  end
end
