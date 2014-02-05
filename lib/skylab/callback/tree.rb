module Skylab

  module Callback

    class Tree # read [#023] the different kinds of callback patterns

      def initialize hash, identifier_x = self.class

        @identifier_x = identifier_x
        p = -> h do
          h.keys.each do |k|
            x = h[ k ]
            cls = NODE_CLASS_H__[ x ]
            h[ k ] = if cls
              cls.new
            elsif x.respond_to? :keys
              p[ x ]
              Branch__.new x
            else
              raise ::ArgumentError, Say_unknown_pattern__[ x ]
            end
          end
        end
        p[ hash ]
        @root = Branch__.new hash
      end

      Say_unknown_pattern__ = -> x do
        s_a = [ * NODE_CLASS_H__.keys.map { |i| "'#{ i }'" }, 'a hash-like' ]
        "not a known pattern: '#{ x }'. expecting #{
          }#{ Oxford_or[ s_a ] }."
      end

      module Mono_Methods_
        def initialize
          @p = nil ; super
        end
        attr_reader :p
        def attempt_set_mono_no_clobber p
          ! @p and @p = p
        end
      end

      module Poly_Methods_
        def initialize
          @p_a = nil ; super
        end
        attr_reader :p_a
        def add_p p
          ( @p_a ||= [] ) << p ; nil
        end
        def attempt_set_mono_no_clobber p  # #stroypoint-50
          ! @p_a and @p_a = [ p ] and true
        end
      end

      module Symbolic_Callback_Methods_
        attr_reader :callback_x_a
        def add_cb_x x
          ( @callback_x_a ||= [] ) << x ; nil
        end
      end

      class Callback_Leaf__
        include Mono_Methods_
      end

      class Handler_Leaf__
        include Mono_Methods_
        def to_handler_pair
          [ nil, @p ]
        end
        def accept_p x  # experimental support for "glom"
          @p = x ; nil
        end
      end

      class Listeners_Leaf__
        include Symbolic_Callback_Methods_
        include Poly_Methods_
        def retrieve_child i
          raise ::KeyError, "off the end: '#{ i }'"
        end
      end

      class Shorters_Leaf__
        include Symbolic_Callback_Methods_
      end

      NODE_CLASS_H__ = {
        callback: Callback_Leaf__,
        handler: Handler_Leaf__,
        listeners: Listeners_Leaf__,
        shorters: Shorters_Leaf__
      }.freeze

      class Branch__
        include Poly_Methods_  # before below, which intercepts ..
        include Mono_Methods_  #  .. 'attempt_set_mono_no_clobber'

        def initialize h
          @h = h ; super()
        end
        attr_reader :h
        def to_handler_pair
          [ @h, @p ]
        end
        def retrieve_child i
          @h.fetch i
        end
      end

      def set_callback * i_a, p
        set_mono_no_clobber i_a, p
      end

      def set_handler * i_a, p
        set_mono_no_clobber i_a, p
      end

    private
      def set_mono_no_clobber i_a, p
        node = rslv_some_node i_a
        node.attempt_set_mono_no_clobber p or
          raise ::KeyError, "won't clobber exiting '#{ i_a.last }'" ; nil
      end
    public

      def add_listener * i_a, p
        _node = rslv_some_node i_a
        _node.add_p p ; nil
      end

      def add_callback_reference * i_a, x
        _node = rslv_some_node i_a
        _node.add_cb_x x ; nil
      end

      def build_yielder_for * i_a
        node = rslv_some_node i_a
        ::Enumerator::Yielder.new do |x|
          node.p[ x ]  # bind it late
        end
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

      def call_callback * i_a, x
        node = rslv_some_node i_a
        if node.p
          node.p[ x ]
        else
          raise "no callback set for '#{ i_a * ' ' }'"
          # one day we might make a 'call any callback'
        end
      end

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

      def call_listeners_with_map * i_a, p  # [#033]:#the-listeners-pattern
        x_a = rslv_any_listeners_leaf_callback_x_a i_a
        x_a and x_a.each do |x|
          p[ x ]
        end
        SILENT_
      end

      def call_attempters_with_map * i_a, p  # [#033]:#the-attempters-pattern
        trueish_x = nil
        x_a = rslv_any_shorters_leaf_callback_x_a i_a
        x_a and x_a.each do |x|
          trueish_x = p[ x ]
          trueish_x and break
        end
        trueish_x
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

      def rslv_any_listeners_leaf_callback_x_a i_a  # #storypoint-200
        rslv_some_leaf( i_a ).callback_x_a
      end

      def rslv_any_shorters_leaf_callback_x_a i_a
        rslv_some_leaf( i_a ).callback_x_a
      end

      def rslv_some_leaf i_a
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
           }#{ Oxford_and[ branch_s_a ] }#{
            } (for the #{ @identifier_x } callbacks)"
      end

      def glom other
        p = -> me, otr do
          p_ = otr.p and me.accept_p p_
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
    public

      class Mutable_Specification

        def initialize host_module
          @default_pattern_i = :shorters
          @h = { } ; @host_module = host_module
        end

        def default_pattern i
          @default_pattern_i = i
        end

        def << i
          @h[ i ] = @default_pattern_i ; self
        end

        def listeners i
          @h[ i ] = :listeners ; nil
        end

        def shorters i
          @h[ i ] = :shorters ; nil
        end

        def end
          _tree = flush
          @host_module.const_set :Callback_Tree__, _tree ; nil
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

      # ~ mutable conduits

      class Specified_Callback_Tree_

        def build_mutable_conduit
          _cls = mtbl_conduit_class
          _cls.new do |callback_i, p|
            set_callback callback_i, p ; nil
          end
        end
      private
        def mtbl_conduit_class
          cls = self.class
          if cls.const_defined? :Mutable_Conduit__, false
            cls::Mutable_Conduit__
          else
            cls.const_set :Mutable_Conduit__, bld_mutable_conduit_class
          end
        end
      private
        def bld_mutable_conduit_class
          i_a = @root.h.keys
          ::Class.new( Mutable_Conduit__ ).class_exec do
            i_a.each do |m_i|
              define_method m_i do |*a, &p|
                p = ( p ? a << p : a ).fetch a.length - 1 << 1  # normalize 1 p
                @p[ m_i, p ] ; p
              end
            end
            self
          end
        end
      end

      class Mutable_Conduit__
        def initialize & p
          @p = p
        end
      end

      # ~ host

      Host = -> mod do
        mod.send :define_singleton_method,
          :build_mutable_callback_tree_specification,
            Methods::Build_mutable_callback_tree_specification
        mod.include Instance_Methods__ ; nil
      end

      module Instance_Methods__

        def initialize(*)
          init_callback_tree
          super
        end
      private
        def init_callback_tree
          @callbacks = self.class.const_get( :Callback_Tree__, false ).new ; nil
        end
      end


      # ~ methods

      module Methods
        Build_mutable_callback_tree_specification = -> do
          Mutable_Specification.new self
        end
      end

      PROCEDE_ = SILENT_ = nil
    end
  end
end
