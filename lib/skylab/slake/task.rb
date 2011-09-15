require File.expand_path('../../face/cli', __FILE__) # Colors
require File.expand_path('../interpolation', __FILE__)
require File.expand_path('../attribute-definer', __FILE__)

module Skylab
  module Slake
    class SpecificationError < ::RuntimeError; end
    class Task
      include Face::Colors
      include Interpolation
      extend AttributeDefiner
      TarballExtension = /(?:\.tar\.gz|\.tgz)\z/
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
      def parent_graph= parent_graph
        class << self ; self end.send(:define_method, :parent_graph) { parent_graph }
        @has_parent = true
        parent_graph
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
        ui.err.puts("#{me}: #{ohno('failed:')} #{message}")
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
        node = parent_graph.node(@else) or return _fail("node referred to but not defined: #{@else.inspect}")
        node.task_init or return _fail("failed to initialize task.") # wrote to ui hopefully
        node
      end
      def _fail msg # same as class method
        raise SpecificationError.new(msg)
      end
    end
  end
end
