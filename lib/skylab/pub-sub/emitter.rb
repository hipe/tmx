require_relative '../semantic/core'

module Skylab::PubSub
  module Emitter

    COMMON_LEVELS = [:debug, :info, :notice, :warn, :error, :fatal] # didactic, for elsewhere

    def emits *nodes
      events = event_cloud.nodes! nodes
      these = instance_methods.map(&:intern)
      event_cloud.flatten(events).each do |tag|
        unless these.include?(m = "on_#{tag.name}".intern)
          define_method(m) do |&block|
            event_listeners.add_listener tag.name, block
            self
          end
        end
      end
    end
    def event_class= klass
      define_method(:event_class) { klass }
    end
    alias_method :event_class, :'event_class=' #!
    def event_cloud
      @event_cloud ||= begin
        if k = ancestors[(self == ancestors.first ? 1 : 0) .. -3].detect { |m| m.kind_of?(::Class) and m.respond_to?(:event_cloud) }
          ::Skylab::Semantic::Digraph.new(k.event_cloud)
        else
          ::Skylab::Semantic::Digraph.new
        end
      end
    end
  end
  class << Emitter
    def extended mod
      mod.send(:include, InstanceMethods)
    end
    def new *a
      Class.new.class_eval do
        extend Emitter
        emits(*a)
        def error msg # convenience for this common use case (experimental!)
          emit(:error, msg)
          false
        end
        # experimental interface for default constructor: multiple lambdas
        def initialize *blocks
          blocks.each { |b| b.call(self) }
        end
        self
      end
    end
  end
end

module Skylab::PubSub
  class Event < Struct.new(:payload, :tag, :touched)
    def _define_attr_accessors!(*keys)
      (keys.any? ? keys : payload.keys).each do |k|
        singleton_class.send(:define_method, k) { self.payload[k] }
        singleton_class.send(:define_method, "#{k}=") { |v| self.payload[k] = v }
      end
    end
    def initialize tag, *payload
      case payload.size
      when 0 ; payload = nil
      when 1 ; payload = payload.first
        payload.respond_to?(:payload) and payload = payload.payload # shallow copy another event's payload
      end
      super(payload, tag, false)
      Hash === payload and _define_attr_accessors!
      yield self if block_given?
    end
    alias_method :event_id, :object_id
    def is? sym
      tag.is? sym
    end
    def to_s
      payload.to_s
    end
    alias_method :message, :to_s
    def touch!
      tap { |me| me.touched = true }
    end
    alias_method :touched?, :touched
    def type
      tag.name
    end
    def update_attributes! h
      Hash === payload or self.payload = { message: message }
      payload.merge! h
      _define_attr_accessors!
    end
  end
  class EventListeners < Hash
    def add_listener name, block
      block.respond_to?(:call) or
        raise ArgumentError.new("no block given. " <<
          "Your \"block\" argument to add_listener (a #{block.class}) did not respond to \"call\"")
      self[name] ||= []
      self[name].push block
    end
  end
  module InstanceMethods
    # syntax:
    #   build_event <event>                                        # pass thru
    #   build_event { <tag> | <tag-name> } [ payload_item [..] ]
    def build_event *args, &block
      args.size == 0 and raise ArgumentError.new('no')
      if 1 == args.size and args.first.respond_to?(:type) and args.first.respond_to?(:payload)
        block and fail("you cannot re-emit an event and also provide a constructor block.")
        args.first
      else
        tag = args.shift
        Symbol === tag and tag = ( event_cloud_definer.event_cloud[tag] or
          fail("undeclared event type #{tag.inspect} for #{self.class}") )
        event_class.new(tag, *args, &block)
      end
    end
    def emit *args, &block
      if 1 == args.size and args.first.respond_to?(:payload)
        event = args.first
        tag = event.tag
        block and raise ArgumentError.new("can't use block when emitting an event object.")
      else
        type = args.shift
        payload = args
        tag = event_cloud_definer.event_cloud[type] or
          fail("undeclared event type #{type.inspect} for #{self.class}")
      end
      (tag.all_ancestor_names & event_listeners.keys).map { |k| event_listeners[k] }.flatten.each do |prok|
        event ||= build_event(tag, *payload, &block)
        prok.call(* 1 == prok.arity ? [event] : event.payload )
      end.count
    end
    def event_class
      Event
    end
    def event_listeners
      @event_listeners ||= EventListeners.new
    end
    def event_cloud_definer
      singleton_class.instance_variable_defined?('@event_cloud') ? singleton_class : self.class
    end
  end
end

