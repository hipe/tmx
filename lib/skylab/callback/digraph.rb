module Skylab::Callback

  Digraph = ::Module.new  # READ [#019] #storypoint-1

  module Digraph::MMs  # techincally visible to above, but :+#API-private

    def event_stream_graph
      @event_stream_graph ||= build_event_stream_graph
    end

  private

    def build_event_stream_graph  # #storypoint-2
      scn = Callback_::Scn.try_convert ancestors
      cur = found_a = nil
      nil while ( cur = scn.rgets ) && ::Object != cur
      chk = -> do
        if cur.respond_to? :event_stream_graph
          ( found_a ||= [ ] ) << cur
          scn.terminate if ::Class === cur
        end
      end
      check = -> do
        if self == cur
          check = chk
        else
          chk[]
        end
      end
      check[] while cur = scn.gets
      if found_a
        if 1 == found_a.length
          found_a.fetch( 0 ).event_stream_graph.dupe
        else
          Merge_graphs__[ found_a ]
        end
      else
        Digraph::Stream_Digraph__.new  # 1 of 2
      end
    end

    Merge_graphs__ = -> mod_a do  # not even implemented
      mod_a = mod_a.reduce [] do |m, mod|
        if mod.instance_variable_defined? :@event_stream_graph  # ICK sorry
          if mod.event_stream_graph.length.nonzero?
            m << mod
          end
        end ; m
      end
      mod_a.length.nonzero? and raise "implement me - #{
        }merge multiple graphs - (#{ mod_a * ', ' })"
      Digraph::Stream_Digraph__.new  # 2 of 2
    end

    def listeners_digraph * graph_x_a
      event_stream_graph.absorb_nodes graph_x_a, -> stream_symbol do
        # (this hookback is called only when a new node is added to the graph)
        m = "on_#{ stream_symbol }"
        if ! method_defined? m
          define_method m do |*a, &p|
            if p || a.length.nonzero?
              on stream_symbol, *a, &p
            else
              read_handler_for_event_stream_notify m  # you're on your own
            end
          end
        end ; nil
      end ; nil
    end

    #        ~ advanced semantic reflection experiments ~

  private
    def taxonomic_streams * name_a
      event_stream_graph.set_taxonomic_stream_names name_a ; nil
    end
  public
    def is_callback_digraph_module
      true  # future-proof quack-testing
    end
  end  # module methods

  Digraph::Stream__ = ::Class.new Callback_.lib_.digraph_lib.node_class

  class Digraph::Stream_Digraph__ < Callback_.lib_.digraph_lib

    def initialize
      @taxonomic_stream_i_a = nil
      @node_class = Digraph::Stream__
      super
    end

    # ~ :+[#fi-003] a typical child implementation:
    def get_args_for_copy
      super << @taxonomic_stream_i_a
    end
    def init_copy *a, i_a
      @taxonomic_stream_i_a = ( i_a.dup.freeze if i_a )
      super( *a ) ; nil
    end
    # ~

  public

    def ancestors i  # #storypoint-3
      if has? i then walk_pre_order i, 0 end
    end

    # ~ reflection experiments (implementation)

    attr_reader :taxonomic_stream_i_a

    def set_taxonomic_stream_names name_a
      name_a.length.zero? || name_a[ 0 ].respond_to?( :id2name ) or
        raise ::ArgumentError,
          "no implicit conversion of #{ name_a[ 0 ].class } to symbol"
      @taxonomic_stream_i_a and raise "taxonomic stream names is write-once"
      @taxonomic_stream_i_a = name_a.dup.freeze ; nil
    end
  end

  module Digraph::IMs  # #storypoint-4

    #         ~ in rougly lifecycle (and then pre-) order ~

    def on stream_symbol, * a_p, & block  # #storypoint-5
      event_listeners.add_listener stream_symbol, * a_p, & block
    end

  private

    def with_specificity & p
      event_listeners.with_specificity p
    end

    -> do  # #experimental #storypoint-6

      these_a = %i( call_digraph_listeners event_listeners event_stream_graph )

      init_digraph_emitter = -> do  # #storypoint-7

        instance_variable_defined? :@event_stream_graph and fail "re-name me"  # #todo

        @event_stream_graph_p ||= begin  # (some set their own for shenanigans)
          esg =
          if singleton_class.instance_variable_defined? :@event_stream_graph
            singleton_class.event_stream_graph
          else
            self.class.event_stream_graph
          end
          -> { esg }
        end

        @event_listeners ||= Digraph::Listeners__.new  # idem

        a = these_a.select( & self.class.method( :public_method_defined? ) )
        extend Digraph::Slidden_IM__
        a.each { |k| singleton_class.send :public, k }

        nil
      end

      these_a.each do |i|
        define_method i do |*a, &p|
          instance_exec( & init_digraph_emitter )
          send i, *a, &p
        end
      end
      private( * these_a )

    end.call

    #      ~ non-destructive reflection methods (in aesthetic order) ~

  public

    # `listeners_digraph` - part of the reflection API [#014]

    def callback_digraph_has? stream_symbol
      event_stream_graph.has? stream_symbol
    end

    #                      ~ #storypoint-9 ~

    def if_unhandled_streams *a, &b
      if_unhandled :do_include_taxo, :do_build_msg, ( b ? a << b : a )
    end

    def if_unhandled_non_taxonomic_streams *a, &b
      if_unhandled :do_build_msg, ( b ? a << b : a )
    end

    def if_unhandled_stream_names *a, &b
      if_unhandled :do_include_taxo, ( b ? a << b : a )
    end

    def if_unhandled_non_taxonomic_stream_names *a, &b
      if_unhandled ( b ? a << b : a )
    end

  private

    def if_unhandled * a
      u = When_Unhandled__.new a
      i_a = unhandled_stream_graph.names
      u.do_include_taxo or i_a -= some_taxonomic_stream_i_a
      if i_a.length.zero?
        p_x = u.ok_p ; args = nil
      else
        p_x = u.nope_p ; args =
          [ if u.do_build_msg then say_unhandled( u, i_a ) else i_a end ]
      end
      _p = if p_x.respond_to? :call then p_x else method( p_x ) end
      _p[ * args ]
    end

    def unhandled_stream_graph
      event_stream_graph.minus event_listeners._a
    end

    def some_taxonomic_stream_i_a
      event_stream_graph.taxonomic_stream_i_a or raise "there are #{
        }no known taxonomic streams for this #{ self.class }"
    end

    def say_unhandled u, i_a
      "unhandled#{ ' non-taxonomic' if ! u.do_include_taxo } #{
        }event stream#{ 's' if 1 != i_a.length } #{
         }#{ i_a.inspect } of emitter #{ self.class }"
    end

    class When_Unhandled__
      def initialize a
        @do_build_msg = @do_include_taxo = false
        p_a = a.pop
        :do_include_taxo == a[ 0 ] and begin
          @do_include_taxo = true ; a.shift
        end
        :do_build_msg == a[ 0 ] and begin
          @do_build_msg = true ; a.shift
        end
        a.length.nonzero? and raise ::ArgumentError, "unexpected: '#{ a[ 0 ] }'"
        case p_a.length
        when 1 ; @nope_p = p_a[ 0 ] ; @ok_p = EMPTY_P_
        when 2 ; @nope_p, @ok_p = p_a
        else   ; raise ::ArgumentError, "too much/little proc: #{ p_a.length }"
        end
      end
      attr_reader :do_build_msg, :do_include_taxo, :nope_p, :ok_p
    end

    #  ~ misc reflective services

    def build_contextualized_stream_name_from_channel_i channel_i
      Digraph::Contextualized_Stream_Name.
        new channel_i, some_event_stream_graph
    end

    def some_event_stream_graph
      event_stream_graph or raise "no event stream graph"
    end
  end

  module Digraph::Slidden_IM__
  private

    def call_digraph_listeners x, *payload_a  # sacred & holy workhorse: a #center-of-the-unverse
      event = nil ; esg = @event_stream_graph_p.call
      if payload_a.length.zero? && x.respond_to?( :is_event ) && x.is_event
        stream_i = x.stream_symbol ; event = x  # (re-emit an existing event
      else                          # but under a possibly different graph)
        do_build = true
        stream_i = esg.fetch x do
          fail "undeclared event type #{ x.inspect } for #{ self.class }"
        end.normalized_local_node_name  # errors please, it's just x
      end
      ancestor_a = esg.ancestors( stream_i ).to_a
      # (the below line is the central thesis statement of the whole library)
      ( ancestor_a & @event_listeners._a ).each do |k|
        @event_listeners.retrieve( k ).each do |p|
          do_build &&= begin
            event = build_digraph_event( * payload_a, stream_i, esg )  # :+#hook-out
            false
          end
          if 1 == p.arity  # #jump-1
            p[ event ]
          elsif event
            if event.respond_to? :payload_a
              p[ * event.payload_a ]  # nil ok!
            else
              p[ * payload_a ]
            end
          else
            p[ ]
          end
        end
      end
      @event_listeners.emitted  # notify it
      nil  # to attempt a result of *anything* meaningful is always a semll
    end

    def event_listeners
      @event_listeners
    end

    def event_stream_graph
      @event_stream_graph_p.call
    end
  end  # i.m

  class Digraph::Contextualized_Stream_Name

    def initialize stream_i, esg
      esg or never
      @esg_p = -> { esg } ; @stream_i = stream_i
    end

    attr_reader :stream_i

    def is? stream_i
      esg.x_is_kind_of_y @stream_i, stream_i
    end
  private
    def esg
      @esg_p.call
    end
  end

  class Digraph::Listeners__

    def initialize
      @current_group_id = @group_frame_h = @is_in_group = nil
      @a = [] ; @h = {}
    end

    def _a
      @a
    end

    def retrieve x
      @h.fetch x
    end

    def add_listener name, * a, & b

      p = ( b ? ( a << b ) : a ).fetch( ( a.length << 1 ) - 2 )
      p.respond_to? :call or raise ::ArgumentError, "callabled? #{ p.class }"

      if @is_in_group
        group_id = @current_group_id
        p_ = -> * a_ do
          @group_frame_h.fetch group_id do
            @group_frame_h[ group_id ] = true
            p[ * a_ ] ; nil
          end
        end
        1 == p.arity and def p_.arity ; 1 end  # HUGE hack for #jump-1
      else
        p_ = p
      end

      @h.fetch name do
        @a.push name
        @h[ name ] = []
      end.push p_

      p  # for chaining
    end

    -> do  # `with_specificity`

      mutex_h = ::Hash.new { |h, k| h[ k ] = 0 }
        # disallow nested spec. blocks of same emitter

      define_method :with_specificity do |blk|
        ( mutex_h[ object_id ] += 1 ) > 1 and
          raise "specificity blocks cannot be nested."
        @is_in_group = true
        @current_group_id ||= 0
        @current_group_id += 1
        @group_frame_h ||= { }
        blk[ ]
        mutex_h[ object_id ] -= 1
        @is_in_group = false
        nil
      end

    end.call

    def emitted
      @group_frame_h && @group_frame_h.clear
    end
  end  # listeners

  # ~ auxiliary services

  module Digraph  # ad-hoc emitter class producer.

    class << self

      def new * graph_x_a, & edit_p

        ::Class.new( Emitter___ ).class_exec do

          Callback_[ self, :employ_DSL_for_digraph_emitter ]

            public :with_specificity, :call_digraph_listeners  # [#002]
              # objects of this class are not controller-like they are
              # struct-like so this is always the desired interface

          graph_x_a.length.nonzero? and listeners_digraph( * graph_x_a )

          edit_p and class_exec( & edit_p )

          self
        end
      end
    end  # >>

    class Emitter___

      # experimental interface for default constructor: multiple lambdas
      def initialize * p_a
        p_a.each { |p| p[ self ] }
      end

      def error msg  # #courtesy for common method [#sl-112]
        call_digraph_listeners :error, msg ; false
      end

      def to_listener
        Callback_::Selective_Listener.via_digraph_emitter self
      end

      private def build_digraph_event * x_a, i, esg
        Stub_Old_Event___.new x_a, i
      end
    end

    COMMON_LEVELS = %i( debug info notice warn error fatal ).freeze
      # didactic, #bound, :+#deprication:pending

    class Stub_Old_Event___
      def initialize x_a, i
        @payload_a = x_a
      end
      attr_reader :payload_a
    end
  end
end
