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

    #        ~ advanced semantic reflection experiments ~

    def taxonomic_streams * name_a
      event_stream_graph.set_taxonomic_stream_names name_a
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

    #         ~ reflection experiments (implementation) ~

    def set_taxonomic_stream_names name_a
      if @taxonomic_stream_names
        raise "sorry - won't clobber existing taxonomic stream names"
      else
        @taxonomic_stream_names = name_a.dup.freeze
      end
      name_a
    end

    attr_reader :taxonomic_stream_names

  protected

    def initialize
      @taxonomic_stream_names = nil
      @node_class = PubSub::Stream
      super
    end

    #         ~ dupe support ~

    def base_args
      super << @taxonomic_stream_names  # careful
    end

    def base_init *a, taxonomic_stream_names
      super( *a )
      @taxonomic_stream_names = ( if taxonomic_stream_names
        taxonomic_stream_names.dup.freeze
      end )
      nil
    end
  end

  module PubSub::Emitter::InstanceMethods

    # ( for now, it is the policy of this library never to add destructive
    #   public instance methods (e.g something that adds a listener to a
    #   stream, etc.). Those instance methods that have side-effects, e.g. ones
    #   that add listeners to a stream or emit events, are by default protected.
    #   As appropriate to the design of the application the client must
    #   publicize the desired destructive methods explicitly. )
    #
    # ( however there may be some public *non*-destructive i.m's added below..)

  protected

    #         ~ in rougly lifecycle (and then pre-) order ~

    # `on` - add a listener to a stream
    # (for any stream `foo` consider instead using the generated `on_foo`
    # method rather than this one, for better readability. This was created
    # to be used in cases where `foo` is not known until runtime.)

    def on stream_name, *func, &block
      event_listeners.add_listener stream_name, *func, &block
    end

    def with_specificity &blk
      event_listeners.with_specificity( blk )
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

    #         ~ non-destructive reflection methods (in aesthetic order) ~

  public

    def emits? stream_name
      event_stream_graph.has? stream_name
    end

    # `if_unhandled[_non_taxonomic]_stream[_name]s` - a facility for checking
    # that you are handling all of the event streams that you care about.
    #
    # the above name permutes out to 4 methods each of which has the same
    # argument signature: its arguments must fall into one of the
    # following forms (that expands out to many permutations (seven?)):
    #
    # `argument_signature` ::= &block
    #                      |   <callable-ish> [<callable-ish>]
    #
    # `callable-ish` ::= ( proc | symbol )
    #
    # the one-block and one-callable forms are isomorphic in the expected way.
    # a symbol will be "expanded" into a proc by calling `method`
    # hence the receiver must implement a method by that name somewhere
    # (#todo give example of this).
    #
    # these `if_unhandled_[..]` methods all resolve list of stream names that
    # represent those streams that do not have any listeners connected to
    # them [#todo it begs the question..]. we will herein refer to this list as
    # "the result list", even though the list is not (necessarily) the result
    # of the method call, as we are about to explain.
    #
    # if you called the `_non_taxonomic` form it assumes that the emitter
    # has set a list of `taxonomic_streams` whose names will be excluded
    # from the result list. if the emitter does not know of any taxonomic
    # streams at all a runtime error is raised (which avoids accidental silent
    # failure of the ultimate intended purpose of this whole shebang).
    #
    # the argument signature resolves-out to two functions - if a second
    # <callable-ish> was not provided it is effectively the same as using
    # `-> { }` (the no-op function). the first function will be called if
    # the result list is of nonzero length, the second if not. the result
    # of the `if_unhandled_[..]` call is the result of the function called.
    #
    # for the `[..]_names` form of this method, when there is a nonzero length
    # list of unhandled stream names, the first function will be called with
    # the array of names as its sole argument. alternately, if the
    # `[..]_streams` form was called, an appropriate message is passed instead
    # of an array.
    #
    # to raise a runtime error if there are any unhandled stream of self -
    #
    #   if_unhandled_streams :fail
    #
    # (which is equivalent to:)
    #
    #   if_unhandled_streams method( :fail )
    #
    # (which in turn is equivalent to:)
    #
    #   if_unhandled_streams { |msg| fail msg }
    #
    # (idem:)
    #
    #   if_unhandled_streams -> msg { fail msg }
    #
    # to be about as ornate as possible:
    #
    #   ok = if_unhandled_non_taxonomic_stream_names -> name_a do
    #     puts "these stream(s) are not handled: (#{ name_a * ', ' })"
    #     false
    #   end, -> do  # else
    #     puts "all (non-taxonomic) streams are handled."
    #     true
    #   end
    #   # ..
    #
    # (this explanation leaves room for improvement, but the above is
    # everything there is to know, in an albeit condensed form.)

    def if_unhandled_streams *a, &b
      _if_unhandled true, true, a, b
    end

    def if_unhandled_non_taxonomic_streams *a, &b
      _if_unhandled false, true, a, b
    end

    def if_unhandled_stream_names *a, &b
      _if_unhandled true, false, a, b
    end

    def if_unhandled_non_taxonomic_stream_names *a, &b
      _if_unhandled false, false, a, b
    end

    -> do  # `_if_unhandled`
      arg_h = {
        1 => -> a do a << -> { } end,
        2 => -> a do end
      }
      resolve_callable = nil
      define_method :_if_unhandled do |yes_taxonomic, yes_message, a, b|
        err = -> do
          if b
            a.length.nonzero? and break "can't have block and arguments"
            a << b
          end
          arg_h.fetch( a.length )[ a ]
          nil
        end.call
        err and raise ::ArgumentError, err
        name_a = unhandled_stream_graph.names
        if ! yes_taxonomic  # always run even when empty list, trigger errors
          t_a = event_stream_graph.taxonomic_stream_names
          t_a or raise "there are no known `taxonomic_streams` for #{
            }this #{ self.class }"
          name_a -= t_a
        end
        if name_a.length.zero?
           resolve_callable[ self, a.fetch( 1 ) ].call
        else
          res = if ! yes_message then name_a else
            "unhandled#{ ' non-taxonomic' if ! yes_taxonomic } #{
              }event stream#{ 's' if 1 != name_a.length } #{
              }#{ name_a.inspect } of emitter #{ self.class }"
          end
          resolve_callable[ self, a.fetch( 0 ) ].call res
        end
      end
      protected :_if_unhandled
      resolve_callable = -> me, x do
        if x.respond_to? :call then x else me.method( x ) end
      end
    end.call

    def unhandled_stream_graph
      event_stream_graph.minus event_listeners.names
    end
  end

  module PubSub::Emitter::InstanceMethods_  # (see big comment above `the_list`)

  protected

    # `emit` - this is a sacred and holy workhorse method.
    # it is one of the centers of the universe.

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
      ancestor_a = esg.ancestors( stream_name ).to_a
      # (the below line is like the central thesis statement of the whole lib)
      ( ancestor_a & @event_listeners.names ).each do |k|
        @event_listeners.fetch( k ).each do |func|
          if do_build
            do_build = nil
            event = build_event stream_name, *payload_a
          end
          if 1 == func.arity                   # ( tied to [#ps-013] )
            func[ event ]
          elsif event
            if event.respond_to? :payload_a    # #todo remove if never used
              func[ * event.payload_a ]
            else
              func[ * payload_a ]
            end
          else
            func[ ]
          end
        end
      end
      @event_listeners.emitted                 # notify it
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
  # the application and the modality. But what it *is* for is for when
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
      blk.respond_to? :call or raise ::ArgumentError, "callable? #{ blk.class }"
      if @is_in_group
        inner_block = blk
        group_id = @current_group_id
        blk = -> *a do
          @group_frame_h.fetch group_id do
            @group_frame_h[ group_id ] = true
            inner_block[ *a ]
            nil
          end
        end
        if 1 == inner_block.arity
          def blk.arity ; 1 end  # HUGE HACK - so it works here [#ps-013]
        end
      end
      ( @hash.fetch name do add name, [] end ) << blk
      blk  # important - per spec, for chaining
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

  protected

    def initialize
      super
      @is_in_group =              # are we inside of a specificity block now?
        @current_group_id =       # used in a closure to identify each spec. blk
        @group_frame_h = nil      # hash of group id => true per each emit
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
