require File.expand_path('../interpolation', __FILE__)

module Skylab::Face
  class DependencyGraph
    class Task
      include Colors
      include Interpolation
      TarballExtension = /(?:\.tar\.gz|\.tgz)\z/
      class << self
        def build graph, data
          task = new(graph)
          task.update_attributes(data)
          task.valid? or return false
          task
        end
        def attribute sym, opts={}
          @attributes ||= {}
          @attributes[sym] ||= begin
            attr_accessor sym
            { :required => true }
          end
          @attributes[sym].merge!(opts)
        end
        attr_reader :attributes
      end
      def initialize graph
        @graph = graph
        @ui = @graph.ui
      end
      attr_accessor :else
      alias_method :deps?, :else
      def update_attributes data
        data.each do |k, v|
          send("#{k.gsub(' ','_')}=", v)
        end
      end
      def valid?
        if (missing = self.class.attributes.each.select do |k, v|
          v[:required] && instance_variable_get("@#{k}").nil?
        end).any?
          @ui.err.puts("#{task_type_name} is missing required #{missing.map(&:inspect).join(' and ')} field(s).")
          return false
        end
        true
      end
      def task_type_name
        self.class.to_s.match(/([^:]+)\z/)[1].gsub(/([a-z])([A-Z])/){ "#{$1} #{$2}" }.downcase
      end
      alias_method :name, :task_type_name # experimental
      def hi_name
        "  #{hi name}" # highlight the name, whatever that means to the Colors module
      end
      def slake_deps
        dep = @graph.node(@else) or return
        dep.slake
      end
      def dead_end
        @ui.err.puts("#{ohno('dead end:')} Sorry, there are no supporting tasks "<<
          " to help with #{task_type_name.inspect}.")
        false
      end
      def build_dir
        @build_dir ||= begin
          @graph.ui.request[:build_dir] or fail("request does not specify :build_dir")
        end
      end
    end
  end
end
