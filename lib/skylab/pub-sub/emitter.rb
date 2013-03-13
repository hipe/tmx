module Skylab::PubSub

  module Emitter

    COMMON_LEVELS = [ :debug, :info, :notice, :warn, :error, :fatal ].freeze
      # didactic, #bound

    def self.extended mod  # #sl-111
      mod.extend Emitter::ModuleMethods
      mod.send :include, Emitter::InstanceMethods
    end

    def self.new *a # sugar
      ::Class.new.class_exec do

        extend Emitter

        public :emit # [#ps-002] these objects are used exclusively so

        emits(* a )

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
  end

  module Emitter::ModuleMethods

    def emits *graph_ref
      events = event_graph.nodes! graph_ref
      @event_graph.flatten( events ).reduce( nil ) do |_, stream_name|
        m = "on_#{ stream_name }"
        if ! method_defined? m
          define_method m do |&block|
            event_listeners.add_listener stream_name, block
            self
          end
        end
        nil
      end
      nil
    end

    def event_class klass                      # on a module it's a writer
      define_method :event_class do klass end  # on an instance it's a reader
    end

    def event_graph
      @event_graph ||= begin
        a = ancestors             # Get every ancestor except self (if not s.c.)
        a = a[ (self == a.first ? 1 : 0) .. -3 ] # and (ick) Kernel, BasicObject
        found = []                # and of these, you want of all the ancestors
        while mod = a.shift       # that respond_to event_graph, any first class
          if mod.respond_to? :event_graph # and all (non-class) modules up to
            found.push mod        # that class (if any) or the end.  This crazy-
            ::Class == mod.class and break # ness is to allow inventive merging
          end                     # of event graphs (#experimental).
        end
        case found.length
        when 0
          ::Skylab::Semantic::Digraph.new
        when 1
          found.first.event_graph.dupe
        else
          fail 'implement me --merge graphs'
        end
      end
    end
  end

  class Event

    alias_method :event_id, :object_id

    def is_event
      true
    end

    def is? sym
      @stream.is? sym
    end

    attr_accessor :payload

    attr_reader :stream

    def stream_name
      @stream.normalized_local_name
    end

    def to_s
      @payload.to_s
    end

    alias_method :message, :to_s

    def touch!
      @touched = true
      self
    end

    attr_reader :touched

    alias_method :touched?, :touched


    def update_attributes! h
      if ! ( ::Hash === @payload )
        @payload = { message: message }  # urg
      end
      @payload.merge! h
      _define_attr_accessors!
      nil
    end

  protected

    def initialize stream, *payload
      case payload.length
      when 0
        payload = nil
      when 1
        payload = payload.first
        if payload.respond_to?( :is_event ) and payload.is_event
          # shallow-copy another event's payload. we used to just check
          # for respond_to?(:payload) but this got us in to trouble b/c
          # sometimes payloads are themselves controllers
          payload = payload.payload
        end
      end
      @stream = stream
      @touched = false
      @payload = payload
      ::Hash === payload and _define_attr_accessors!
      nil
    end

                                               # this is badly in need of a re-
    def _define_attr_accessors! *keys          # design but for the time being
      @defined_attr_accessors ||= { }          # we want to avoid warnings
      keys = @payload.keys if keys.length.zero?
      keys.each do |key|
        @defined_attr_accessors.fetch key do |k|
          @defined_attr_accessors[ k ] = true
          define_singleton_method( k ) { @payload[ k ] }
          define_singleton_method( "#{ k }=" ) { |v| @payload[ k ] = v }
        end
      end
      nil
    end
  end

  class Event::Listeners < MetaHell::Formal::Box
    def add_listener name, blk
      blk.respond_to? :call or raise ::ArgumentError, "callable? #{ blk.class }"
      @hash.fetch name do
        add name, []
      end.push blk
      nil
    end
  end


  module Emitter::InstanceMethods

  protected

    # syntax:
    #   build_event <event>                                        # pass thru
    #   build_event { <stream> | <stream-name> } [ payload_item [..] ]
    def build_event *args, &block
      args.size == 0 and raise ArgumentError.new('no')
      if 1 == args.size and args.first.respond_to?(:type) and args.first.respond_to?(:payload)
        block and fail("you cannot re-emit an event and also provide a constructor block.")
        args.first
      else
        stream = args.shift
        Symbol === stream and stream = ( event_graph_definer.event_graph[stream] or
          fail("undeclared event type #{stream.inspect} for #{self.class}") )
        event_class.new(stream, *args, &block)
      end
    end

    def emit *args
      if 1 == args.length &&
          args.first.respond_to?(:is_event) && args.first.is_event then
        event = args.first
        stream = event.stream
      else
        stream_name = args.shift
        payload = args
        stream = event_graph_definer.event_graph[ stream_name ]
        fail "undeclared event type #{ stream_name.inspect } #{
          }for #{ self.class }" if ! stream
      end
      a = (stream.all_ancestor_names & event_listeners.names).reduce [] do |m,k|
        m.concat @event_listeners.fetch( k )
        m
      end
      a.each do |func|
        event ||= build_event stream, *payload  # note no block
        func.call(* 1 == func.arity ? [ event ] : event.payload )
      end
      nil  # (we used to result in a count of listeners but what a smell!)
    end

    def emits? event_name
      event_graph_definer.event_graph.has? event_name
    end

    def event_class
      Event
    end

    def event_listeners
      @event_listeners ||= Event::Listeners.new
    end

    def event_cloud_definer
      if singleton_class.instance_variable_defined? :@event_graph
        singleton_class
      else
        self.class
      end
    end

    def event_graph_definer
      singleton_class.instance_variable_defined?('@event_graph') ? singleton_class : self.class
    end

    def unhandled_event_streams
      fail '# #todo'
    end
  end
end
