require File.expand_path('../../face/cli', __FILE__) # Colors
require File.expand_path('../interpolation', __FILE__)
require File.expand_path('../attribute-definer', __FILE__)

module Skylab
  module Slake
    class RuntimeError < ::RuntimeError; end
    class SpecificationError < RuntimeError; end
    class Task
      include Face::Colors
      include Interpolation
      extend AttributeDefiner
      def initialize
        # Keep this one empty, force arugment errors on arguments.
        # State no explicity logic for initialization
        # With subclasses it's ok to override
      end
      attribute :enabled, :required => false

      attr_accessor :else
      attr_accessor :ui
      def update_attributes data
        data.each do |k, v|
          send("#{k.gsub(' ','_')}=", v)
        end
      end
      def disabled?
        ! (@enabled.nil? || @enabled)
      end
      def valid?
        if (missing = self.class.attributes.each.select do |k, v|
          v[:required] && instance_variable_get("@#{k}").nil?
        end).any?
          return _fail("#{task_type_name} is missing required #{ missing.map{ |x| x.first.to_s.inspect }.join(' and ') } field(s).")
        end
        true
      end
      def task_type_name
        self.class.to_s.match(/([^:]+)\z/)[1].gsub(/([a-z])([A-Z])/){ "#{$1} #{$2}" }.downcase
      end
      def name= name
        @name = name
      end
      def name
        @name || task_type_name
      end
      def long_name
        @name ? "#{@name} : #{task_type_name}" : task_type_name
      end
      def me
        "  #{hi name}" # highlight the name, whatever that means to the Colors module
      end
      def meet_parent_graph parent_graph
        @has_parent and fail("can't add multiple parents")
        class << self ; self end.send(:define_method, :parent_graph) { parent_graph }
        @parent_accessor = :parent_graph
        @has_parent = true
        self
      end
      def children
        # for subclasses to implement where useful
      end
      attr_reader :has_parent
      alias_method :has_parent?, :has_parent
      def request
        parent_graph.request
      end
      def dead_end
        ui.err.puts("#{ohno('dead end:')} Sorry, there are no supporting tasks "<<
          " to help with #{task_type_name.inspect}.")
        false
      end
      def nope message
        ui.err.puts("#{_prefix}#{me}: #{ohno('nope:')} #{message}")
        false
      end
      def undo
        a = b = true
        if @else
          dep = parent_graph.node(@else)
          a = dep.undo
        end
        if respond_to?(:_undo)
          b = _undo
        end
        a && b
      end
      def _undo
        ui.err.puts "(No undo defined for #{hi long_name}.)"
      end
    protected
      def fallback?
        ! @else.nil?
      end
      def fallback
        @else or return _fail("fallback task needed for #{long_name.inspect} but no \"else\" node provided.")
        deps = (@else.kind_of?(Array) ? @else : [@else]).map do |node_name|
          parent_graph.node(node_name) or _fail("node referred to but not defined: #{node_name.inspect}")
        end
        deps.size == 1 ? deps.first : Aggregate.new(deps)
      end
      def _fail msg # this must throw!
        raise SpecificationError.new(msg)
      end
    end
    class Aggregate < Array
      def initialize arr
        did = {}
        sing = class << self; self end
        arr.each_with_index do |x, i|
          push x
          x.interpolated_via_methods.each do |intern|
            did[intern] ||= begin
              sing.send(:define_method, "interpolate_#{intern}") { x.send("interpolate_#{intern}") }
              true
            end
          end
        end
      end
      def slake
        ! map(&:slake).index { |v| ! v }
      end
      def check
        ! map(&:check).index { |v| ! v }
      end
    end
  end
end
