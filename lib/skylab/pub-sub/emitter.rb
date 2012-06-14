module Skylab ; end

module Skylab::PubSub
  module Emitter

    COMMON_LEVELS = [:debug, :info, :notice, :warn, :error, :fatal] # didactic, for elsewhere

    def emits *nodes
      event_cloud = self.event_cloud
      events = event_cloud.merge_definition!(*nodes)
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
        if (k = ancestors[self == ancestors.first ? 1 : 0]).respond_to?(:event_cloud)
          SemanticTagCloud.new(k.event_cloud)
        else
          SemanticTagCloud.new
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
        Symbol === tag and tag = ( event_cloud_definer.event_cloud.lookup_tag(tag) or
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
        tag = event_cloud_definer.event_cloud.lookup_tag(type) or
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
  class SemanticTagCloud < Hash
    def all_ancestors tag
      Enumerator.new do |y|
        seen  = {}
        found = []
        visit = ->(k) do
          t = self[k] or t = merge_definition!(k).first
          seen[t.name] = true
          y << t
          ( t.parent_names - found ).each { |s| seen[s] or visit[s] } # !
        end
        visit[tag.name]
      end
    end
    def _deep_copy_init other
      @order = other.instance_variable_get('@order').dup
      @order.each do |k|
        self[k] = other[k].duplicate
      end
    end
    def describe
      @order.map { |key| self[key].describe }.join("\n")
    end
    def flatten tags
      order = []
      seen = Hash.new { |h, k| order.push k; h[k] = true }
      tags.each do |tag|
        tag.parent_names.each { |k| seen[k] }
        seen[tag.name]
      end
      order.map { |k| self[k] }
    end
    def initialize other=nil
      if other
        _deep_copy_init other
      else
        @order = []
      end
    end
    alias_method :lookup_tag, :[] # more readable code
    def merge_definition! *nodes
      resulting_tags = []
      nodes.each do |node|
        case node
        when Symbol
          resulting_tags.push merge_tag!(Tag.new(node, self))
        when Hash
          resulting_tags.concat( node.map { |k, v|
            parent_names = case v
            when Array  ; v
            when Symbol ; [v]
            else        ; raise ArgumentError.new("need Array or Symbol had #{v.class}:#{v}")
            end
            merge_tag! Tag.new(k, self, :parent_names => parent_names)
          } )
        else raise ArgumentError.new("need Symbol or Hash had #{node.class}:#{node}")
        end
      end
      resulting_tags
    end
    def merge_tag! tag
      tag.parent_names.each do |parent|
        (self[parent] ||= Tag.new(parent, self)).children_names |= [tag.name]
      end
      if key?(tag.name)
        self[tag.name].merge!(tag)
      else
        @order.push tag.name
        self[tag.name] = tag
      end
    end
  end
  class Tag
    def all_ancestor_names
      @cloud.all_ancestors(self).map(&:name)
    end
    def duplicate
      self.class.new(@name, cloud, :parent_names => @parent_names.dup, :children_names => @children_names.dup)
    end
    def initialize name, cloud, opts=nil
      name.kind_of?(Symbol) or raise ArgumentError.new("need symbol had #{name.class}")
      @cloud = cloud
      @name = name
      opts and opts.each { |k, v| send("#{k}=", v) }
      @parent_names ||= []
      @children_names = []
    end
    attr_accessor :parent_names
    attr_accessor :children_names
    attr_reader :cloud
    def describe
      [@name.to_s, (@parent_names.join(', ') if @parent_names.any?)].compact.join(' -> ')
    end
    def is? tag_name
      cloud.all_ancestors(self).detect { |t| tag_name == t.name }
    end
    def merge! tag
      tag.name == @name or fail("need same tag name to merge tags (#{@name.inspect} != #{tag.name.inspect})")
      @parent_names |= tag.parent_names
      self
    end
    attr_reader :name
  end
end

