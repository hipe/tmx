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
      alias_method :deps?, :else
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
      def me
        "  #{hi name}" # highlight the name, whatever that means to the Colors module
      end
      def request
        parent_graph.request
      end
      def slake_else
        dep = parent_graph.node(@else) or return
        dep.slake
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
    protected
      def need_else
        @else or return _fail("needed @else node!")
        node = parent_graph.node(@else) or return _fail("node not defined: #{@else.inspect}")
        node
      end
      def _fail msg # same as class method
        raise SpecificationError.new(msg)
      end
    end
  end
end
