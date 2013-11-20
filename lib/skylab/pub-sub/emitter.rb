module Skylab::PubSub

  module Emitter  # READ [#019] #storypoint-1

    def self.extended mod  # #sl-111
      mod.extend Emitter::ModuleMethods
      mod.send :include, Emitter::IM__
    end
  end

  module Emitter::ModuleMethods  # (yes, part of our public API)

    def event_stream_graph
      @event_stream_graph ||= build_event_stream_graph
    end

  private

    def build_event_stream_graph  # #storypoint-2
      scn = Basic::List::Scanner[ ancestors ] ; cur = found_a = nil
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
        Emitter::Stream_Digraph__.new  # 1 of 2
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
      Emitter::Stream_Digraph__.new  # 2 of 2
    end

    def emits * graph_x_a
      event_stream_graph.absorb_nodes graph_x_a, -> stream_name do
        # (this hookback is called only when a new node is added to the graph)
        m = "on_#{ stream_name }"
        if ! method_defined? m
          define_method m do |*a, &p|
            if p || a.length.nonzero?
              on stream_name, *a, &p
            else
              read_handler_for_event_stream_notify m  # you're on your own
            end
          end
        end ; nil
      end ; nil
    end

    def event_class cls_x  # #writer-here-reader-there
      define_method :event_class, ( if cls_x.respond_to? :call then cls_x else
        -> { cls_x }
      end ) ; nil
    end

    def event_factory factory_x  # #writer-here-reader-there
      define_method :build_event_factory, (
        if factory_x.respond_to? :arity and factory_x.arity.zero?
          factory_x
        else
          -> { factory_x }
        end )
    end

    def use_default_event_factory  # e.g if the superclass customized it
      alias_method :build_event_factory, :default_build_event_factory ; nil
    end

    #        ~ advanced semantic reflection experiments ~

  private
    def taxonomic_streams * name_a
      event_stream_graph.set_taxonomic_stream_names name_a ; nil
    end
  public
    def is_pub_sub_emitter_module
      true  # future-proof quack-testing
    end
  end  # module methods

  Emitter::Stream__ = ::Class.new Basic::Digraph::Node

  class Emitter::Stream_Digraph__ < Basic::Digraph

    def initialize
      @taxonomic_stream_i_a = nil
      @node_class = Emitter::Stream__
      super
    end

    # ~ dupe support

  private
    def base_args
      super << @taxonomic_stream_i_a
    end

    def base_init *a, any_taxo_stream_i_a
      @taxonomic_stream_i_a = ( if any_taxo_stream_i_a
        any_taxo_stream_i_a.dup.freeze
      end )
      super( *a ) ; nil
    end
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

  module Emitter::IM__ # #storypoint-4

    #         ~ in rougly lifecycle (and then pre-) order ~

  private

    def on stream_name, * a_p, & block  # #storypoint-5
      event_listeners.add_listener stream_name, * a_p, & block
    end

    def with_specificity & p
      event_listeners.with_specificity p
    end

    -> do  # #experimental #storypoint-6

      these_a = %i( emit event_listeners event_stream_graph )

      init_emitter = -> do  # #storypoint-7

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

        @event_factory ||= build_event_factory  # idem

        @event_listeners ||= Emitter::Listeners__.new  # idem

        a = these_a.select( & self.class.method( :public_method_defined? ) )
        extend Emitter::Slidden_IM__
        a.each { |k| singleton_class.send :public, k }

        nil
      end

      these_a.each do |i|
        define_method i do |*a, &p|
          instance_exec( & init_emitter )
          send i, *a, &p
        end
      end
      private( * these_a )

    end.call

    #      ~ non-destructive reflection methods (in aesthetic order) ~

  public

    # `emits` - part of the reflection API [#ps-014]

    def emits? stream_name
      event_stream_graph.has? stream_name
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
      event_stream_graph.minus event_listeners.names
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
        when 1 ; @nope_p = p_a[ 0 ] ; @ok_p = MetaHell::EMPTY_P_
        when 2 ; @nope_p, @ok_p = p_a
        else   ; raise ::ArgumentError, "too much/little proc: #{ p_a.length }"
        end
      end
      attr_reader :do_build_msg, :do_include_taxo, :nope_p, :ok_p
    end

    # ~ event production

    def build_event stream_name, *payload_a
      @event_factory.call @event_stream_graph_p.call, stream_name, *payload_a
    end

    def build_event_factory  # expected to be called once per instance..
      -> esg, stream_name, *payload_a do
        event_class.new esg, stream_name, *payload_a
      end
    end
    alias_method :default_build_event_factory, :build_event_factory

    def event_class
      PubSub::Event::Unified  # a default
    end

    #  ~ misc reflective services

    def build_contextualized_stream_name_from_channel_i channel_i
      Emitter::Contextualized_Stream_Name.
        new channel_i, some_event_stream_graph
    end

    def some_event_stream_graph
      event_stream_graph or raise "no event stream graph"
    end

  end

  module Emitter::Slidden_IM__
  private

    def emit x, *payload_a  # sacred & holy workhorse: a #center-of-the-unverse
      event = nil ; esg = @event_stream_graph_p.call
      if payload_a.length.zero? && x.respond_to?( :is_event ) && x.is_event
        stream_i = x.stream_name ; event = x  # (re-emit an existing event
      else                          # but under a possibly different graph)
        do_build = true
        stream_i = esg.fetch x do
          fail "undeclared event type #{ x.inspect } for #{ self.class }"
        end.normalized_local_node_name  # errors please, it's just x
      end
      ancestor_a = esg.ancestors( stream_i ).to_a
      # (the below line is the central thesis statement of the whole library)
      ( ancestor_a & @event_listeners._order ).each do |k|
        @event_listeners.fetch( k ).each do |p|
          do_build &&= begin
            event = build_event stream_i, *payload_a
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

  class Emitter::Contextualized_Stream_Name

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

  class Emitter::Listeners__ < MetaHell::Formal::Box

    def initialize
      @current_group_id = @group_frame_h = @is_in_group = nil
      super
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
      ( @hash.fetch name do add name, [ ] end ) << p_
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

  module Emitter  # ad-hoc emitter class producer.

    def self.new * graph_x_a, & p

      ::Class.new.class_exec do

        extend Emitter

        class << self
          public :event_class, :event_factory
        end

        public :with_specificity, :emit  # [#002] objects of this class
          # are not controller-like they are struct-like so this is always
          # the desired interface

        graph_x_a.length.nonzero? and emits( * graph_x_a )

        # experimental interface for default constructor: multiple lambdas
        def initialize * p_a
          p_a.each { |p| p[ self ] }
        end

        def error msg  # #courtesy for common method [#sl-112]
          emit :error, msg ; false
        end

        p and class_exec( & p )

        self
      end
    end

    COMMON_LEVELS = %i( debug info notice warn error fatal ).freeze
      # didactic, #bound, #deprecated

  end
end
