module Skylab ; end

module Skylab::PubSub
  module Emitter
    def self.extended mod
      mod.send(:include, InstanceMethods)
    end
    def emits *nodes
      event_cloud = self.event_cloud
      events = event_cloud.merge_definition! *nodes
      these = instance_methods.map(&:intern)
      event_cloud.flatten(events).each do |tag|
        unless these.include?(m = "on_#{tag.name}".intern)
          define_method(m) do |&block|
            event_listeners.add_listener tag.name, block
          end
        end
      end
    end
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
end

module Skylab::PubSub::Emitter
  class Event
    attr_reader :data
    def initialize tag, data
      @data = data
      @tag = tag
      @touched = false
    end
    alias_method :event_id, :object_id
    def message
      @touched = true
      @data.to_s
    end
    alias_method :to_s, :message
    def touch
      @touched = true
    end
    attr_accessor :touched # set this to false only if you are trying to be clever
    alias_method :touched?, :touched
    def type
      @tag.name
    end
  end
  class EventListeners < Hash
    def add_listener name, block
      self[name] ||= []
      self[name].push block
    end
  end
  module InstanceMethods
    def emit type, data=nil
      cloud = _find_event_cloud
      tag = cloud[type] or fail("undeclared event type: #{type.inspect}")
      el = event_listeners
      event = nil
      cloud.ancestor_names(tag).map{ |n| el[n] }.compact.flatten.tap do |a|
        a.each { |b| b.call(event ||= Event.new(tag, data)) }
      end.count
    end
    # sucks for now
    def _find_event_cloud
      singleton_class.instance_variable_defined?('@event_cloud') and return singleton_class.event_cloud
      self.class.event_cloud
    end
    def event_listeners
      @event_listeners ||= EventListeners.new
    end
  end
  class SemanticTagCloud < Hash
    def ancestor_names tag
      seen  = {}
      found = []
      visit = ->(t) do
        seen[t.name] = t
        found.push t.name
        ( t.ancestors - found ).each { |s| seen[s] or visit[self[s]] } # !
      end
      visit[tag]
      found
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
        tag.ancestors.each { |k| seen[k] }
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
    def merge_definition! *nodes
      resulting_tags = []
      nodes.each do |node|
        case node
        when Symbol
          resulting_tags.push merge_tag!(Tag.new(node))
        when Hash
          resulting_tags.concat( node.map { |k, v|
            ancestors = case v
            when Array  ; v
            when Symbol ; [v]
            else        ; raise ArgumentError.new("need Array or Symbol had #{v.class}:#{v}")
            end
            merge_tag! Tag.new(k, :ancestors => ancestors)
          } )
        else raise ArgumentError.new("need Symbol or Hash had #{node.class}:#{node}")
        end
      end
      resulting_tags
    end
    def merge_tag! tag
      tag.ancestors.each do |parent|
        (self[parent] ||= Tag.new(parent)).children |= [tag.name]
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
    def duplicate
      self.class.new(@name, :ancestors => @ancestors.dup, :children => @children.dup)
    end
    def initialize name, opts=nil
      name.kind_of?(Symbol) or raise ArgumentError.new("need symbol had #{name.class}")
      @name = name
      opts and opts.each { |k, v| send("#{k}=", v) }
      @ancestors ||= []
      @children = []
    end
    attr_accessor :ancestors
    attr_accessor :children
    def describe
      [@name.to_s, (@ancestors.join(', ') if @ancestors.any?)].compact.join(' -> ')
    end
    def merge! tag
      tag.name == @name or fail("need same tag name to merge tags (#{@name.inspect} != #{tag.name.inspect})")
      @ancestors |= tag.ancestors
      self
    end
    attr_reader :name
  end
end

