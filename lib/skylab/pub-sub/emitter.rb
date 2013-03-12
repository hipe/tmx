module Skylab::PubSub

  #         ~ presented in semantic, narrative pre-order traversal ~

  module PubSub::Emitter
    def self.extended mod  # #sl-111
      mod.extend Emitter::ModuleMethods
      mod.send :include, Emitter::InstanceMethods
    end
  end

  module PubSub::Emitter::ModuleMethods

    def event_stream_graph

      @event_stream_graph ||= begin
        # Traverse up the chain of every ancestor except self (and self is
        # not in the chain if we are an s.c), (also we (ick) skip ::Kernel
        # and ::BasicObject which will not fly if etc #todo) and for each
        # module that `respond_to` `event_stream_graph`, add it to a list,
        # and if ever one of these nerks is a class stop right then and there
        # assuming that (if we understand the ancestor chain correctly) that
        # inheritence itself (in conjunction with this facility) will work.
        # All of this craziness is to allow the merging of graphs on top
        # of ancestor graphs, to see if that is a thing that is useful, but
        # of course, it is all #experimental so use with caution.

        a = ancestors
        a = a[ (self == a.first ? 1 : 0) .. -3 ] # (#ick Kernel, BasicObject)
        found = a.reduce [] do |fnd, mod|
          if mod.respond_to? :event_stream_graph
            fnd << mod
            break fnd if ::Class == mod.class
          end
          fnd
        end
        case found.length
        when 0
          PubSub::Stream::Digraph.new  # 2x
        when 1
          found.first.event_stream_graph.dupe
        else
          PubSub::FUN.merge_graphs[ found ]
        end
      end
    end

  protected  # outside nerks should not berk your derk

    def emits *graph_ref
      event_stream_graph.absorb_nodes graph_ref, -> stream_name do
        # (this hookback is called only when a new node is added to the graph)
        m = "on_#{ stream_name }"
        if ! method_defined? m
          define_method m do |*a, &b|          # (a/b - func or block, exclusive)
            on stream_name, *a, &b
          end
        end
        nil
      end
      nil
    end

    def event_class klass                      # on a module it's a writer
      if klass.respond_to? :call
        define_method :event_class, &klass
      else
        define_method :event_class do klass end  # on an instance it's a reader
      end
      nil
    end

    def event_factory callable                 # on a module it's a writer
      if callable.respond_to? :arity and 0 == callable.arity
        define_method :build_event_factory do  # when it looks like this we
          callable.call           # assume that what was passed was a forward-
        end                       # reference-style block around the factory
      else                        # otherwise we assume that what was passed
        define_method :build_event_factory do  # is the callable factory itself.
          callable                # (if you really needed to set a factory that
        end                       # takes zero arguments, you still could, but
      end                         # eew 2x)
      nil
    end
  end

  class PubSub::Stream < Semantic::Digraph::Node  # (stowaway) used above
  end

  class PubSub::Stream::Digraph < Semantic::Digraph

    # `ancestors` - the central workhorse of `emit` - if `sym` is in the graph,
    # result is an enumerator of names with `sym` always being the first one,
    # and the remainder being the unique set, pre-ordered, of all assiociation
    # target names (direct and indirect) of `sym`. if `sym` is not in the
    # graph result is undefined (probably exception).

    def ancestors sym
      walk_pre_order( sym, 0 ) if has? sym
    end

  protected

    def initialize
      @node_class = PubSub::Stream
      super
    end
  end

  module PubSub::Emitter::InstanceMethods

    # (no public methods added by pub-sub)

  protected

    #         ~ in rougly lifecycle (and then pre-) order ~

    # `on` - add a listener to a stream
    # (for any stream `foo` consider instead using the generated `on_foo`
    # method rather than this one, for better readability. This was created
    # to be used in cases where `foo` is not known until runtime.)

    def on stream_name, *func, &block
      event_listeners.add_listener stream_name, *func, &block
    end

    -> do

      #                       ~ EXPERIMENTAL ~

      # NOTE we try something here as one of many different attempts at a
      # solution for a familiar design problem that yet has no name -
      # the below 3 methods trigger a call to `init` which hackishly adds
      # another module to the ancestor chain of the singleton class of the
      # object, which in turn overrides these methods!! this is done so
      # that we don't have to check for whether the thing is initted each
      # time we for e.g. call `emit`, and in theory it will only get us in
      # to trouble if we use alias_method on the below three #experimental

      the_list = [ :emit, :event_listeners, :event_stream_graph ]  # used 2x

      init = nil  # scope

      the_list.each do |m|
        define_method m do |*a|
          instance_exec(& init )
          send m, *a
        end
        protected m
      end

      # `init`
      # + we collapse the particular graph here (i.e we decide what graph is
      # your graph, be it from your singleton class or your class.)
      # + it is memoized to a proc for devious reasons.
      # + you can always clear the ivar and/or set it to whatever yourself.

      init = -> do
        # for each of the below 3 things, some clients will have set their
        # own before they get here (e.g h.l table with it's experimental
        # conduit / engine pattern omg)

        @event_stream_graph ||= begin  # (some set their own for shenanigans)
          esg =
          if singleton_class.instance_variable_defined? :@event_stream_graph
            singleton_class.event_stream_graph
          else
            self.class.event_stream_graph
          end
          -> { esg }
        end

        @event_factory ||= build_event_factory  # idem

        @event_listeners ||= PubSub::Event::Listeners.new  # idem

        omg = the_list.select(& self.class.method( :public_method_defined? ) )
        extend PubSub::Emitter::InstanceMethods_
        omg.each { |k| singleton_class.send :public, k } # it was so perfect

        nil
      end
    end.call

    #                       ~ event production ~

    # `build_event` - this is both a convenience for clients that want to
    # build an event for whatever reason, *and* it can be extended and
    # wrapped by a class that wants to touch every event that it emits.
    # it cann even be re-written completely, for e.g to pass more or different
    # info to your factory, or whatever.

    def build_event stream_name, *payload_a
      @event_factory.call @event_stream_graph.call, stream_name, *payload_a
    end

    def build_event_factory  # expected to be called once per instance..
      -> esg, stream_name, *payload_a do
        event_class.new esg, stream_name, *payload_a
      end
    end

    def event_class
      PubSub::Event::Unified  # a default
    end

    #         ~ convenience reflection methods (alphabetical) ~

    def emits? stream_name
      event_stream_graph.has? stream_name
    end

    def unhandled_event_stream_graph
      event_stream_graph.minus event_listeners.names
    end
  end

  module PubSub::Emitter::InstanceMethods_  # (see big comment above `the_list`)

  protected

    def emit x, *payload_a
      esg = @event_stream_graph.call
      if 0 == payload_a.length && x.respond_to?( :is_event ) && x.is_event
        stream_name = x.stream_name ; event = x  # (re-emit an existing event
      else                        # but use a possibly different graph)
        do_build = true
        stream_name = esg.fetch( x ) do
          fail "undeclared event type #{ x.inspect } for #{ self.class }"
        end.normalized_local_node_name  # errors please, it's just x
      end
      ancestors = esg.ancestors( stream_name ).to_a
      # (the below line is like the central thesis statement of the whole lib)
      ( ancestors & @event_listeners.names ).each do |k|
        @event_listeners.fetch( k ).each do |func|
          if do_build
            do_build = nil
            event = build_event stream_name, *payload_a
          end
          if 1 == func.arity
            func[ event ]
          elsif event
            if event.respond_to? :payload_a   # #todo remove if never used
              func[ * event.payload_a ]
            else
              func[ * payload_a ]
            end
          else
            func[ ]
          end
        end
      end
      nil  # (we used to result in a count of listeners but what a smell!)
    end

    #         ~ courtesy accessors and nerkins in alpha. order ~

    attr_reader :event_listeners

    def event_stream_graph
      @event_stream_graph.call
    end
  end


  # `PubSub::Event::Unified` - when you want your events to be just simple
  # datapoints like strings or numbers (or any single arbitrary object),
  # that you want to emit out to listeners, you will not have to use this
  # (but you instead will have to wire a factory, which may just be one line..)
  #
  # Out of the box the PubSub::Event::Unified doesn't know how to render
  # itself or its payload, because that depends on the payload itself,
  # the application and the modality.  But what it *is* for is for when
  # you want the event object itself to be able to reflect metadata
  # about the event, like`e.is? :error` or `e.touched?`. *or* you plan
  # to corral all of your events through e.g one filter or aggregator
  # and you want them all to have the same core interface. (this used to
  # be how it was always done before we realized that datapoints were
  # more elegant for some problems.)
  #
  # (Historical note: we used to rely on this heavily when we would do
  # contorted hacks to contextualize and decorate event messages, for e.g.
  # changing its message by prefacing a verb and a noun constructed from
  # a fully qualified API action name.. but we may be trending away from
  # it now in lieu of carefully wired factories, and carefully constructed
  # stream graphs, and custom (and lightweight) event classes per-application
  # .. let's see..)
  #

  module PubSub::Event
    extend MetaHell::Autoloader::Autovivifying::Recursive
    # (file placement might change.. for now it's a jumble)
  end

  class PubSub::Event::Unified

    extend MetaHell::Autoloader::Autovivifying::Recursive

    attr_reader :event_id

    def is_event
      true
    end

    def is? sym
      !! event_stream_graph.walk_pre_order( @stream_name, 0 ).detect do |sm|
        sym == sm
      end
    end

    attr_reader :payload_a

    attr_reader :stream_name

    def touch!
      @is_touched = true
      self
    end

    attr_reader :is_touched

    alias_method :touched?, :is_touched

    undef_method :to_s  # #todo - remove after integration

  protected

    next_id = -> do
      nxt_id = 0
      -> { nxt_id += 1 }
    end.call

    # *highly* #experimental args. handling of payload is left intentionally
    # sparse here, different applications will process and present payloads
    # differently.

    define_method :initialize do |esg, stream_name, *payload|
      @event_id = next_id[ ]
      @is_touched = false
      @stream_name = stream_name
      if esg
        if esg.respond_to? :call
          fail 'where'
        else
          @event_stream_graph_ref = -> { esg }
        end
      elsif esg.nil?
        fail 'where'
      else
        @event_stream_graph_ref = esg  # allow false - intentionally not set
      end
      if payload.length.nonzero?
        @payload_a = payload  # don't confuse subclass instances by setting this
      end
      nil
    end

    def event_stream_graph
      @event_stream_graph_ref.call
    end
  end

  class PubSub::Event::Textual < PubSub::Event::Unified

    # (consider also just wiring a factory that creates as an event objects
    # just pure text ..)

    attr_reader :text

  protected

    def initialize esg, stream_name, text
      super esg, stream_name
      @text = text
      nil
    end
  end

  class PubSub::Event::Listeners < MetaHell::Formal::Box
    def add_listener name, func=nil, &blk
      if func
        blk and raise ::ArgumentError, "too many arguments (func and block?)"
        blk = func
      end
      if blk.respond_to? :call
        @hash.fetch name do add name, [] end.push blk
      else
        raise ::ArgumentError, "callable? #{ blk.class }" # #todo - take this out after allgreen
      end
      blk  # important - per spec, for chaining
    end
  end

  PubSub::FUN = -> do
    o = { }

    o[:merge_graphs] = -> mod_a do
      arr = mod_a.reduce [] do |m, mod|
        if mod.instance_variable_defined? :@event_stream_graph  # ICK sorry
          esg = mod.event_stream_graph
          if esg.length.nonzro?
            m << mod
          end
        end
        m
      end
      if arr.length.nonzero?
        fail "implement me - merge multiple graphs - (#{ arr.join ', ' })"
      else
        PubSub::Stream::Digraph.new  # 2x
      end
    end

    fun = ::Struct.new(* o.keys ).new ; o.each { |k, v| fun[k] = v } ;fun.freeze
  end.call

  #                           ~ auxiliary ~

  module PubSub::Emitter  # ad-hoc emitter class producer.

    def self.new *graph_ref

      ::Class.new.class_exec do

        extend PubSub::Emitter

        public :emit # [#ps-002] these objects are used exclusively so

        class << self
          public :event_class, :event_factory
        end

        if graph_ref.length.nonzero?
          emits(* graph_ref )
        end

        def error msg # provided as a courtesy for this common #pattern #sl-112
          emit :error, msg
          false
        end

      protected

        # experimental interface for default constructor: multiple lambdas
        def initialize *blocks
          blocks.each { |b| b.call self }
        end

        self
      end
    end

    #                           ~ constants ~

    COMMON_LEVELS = [ :debug, :info, :notice, :warn, :error, :fatal ].freeze
      # didactic, #bound, #deprecated

  end
end
