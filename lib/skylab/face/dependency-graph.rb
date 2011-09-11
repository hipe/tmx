require 'json'
require File.expand_path('../open2', __FILE__)
require File.expand_path('../path-tools', __FILE__)
require File.expand_path('../dependency-graph/task', __FILE__)
require File.expand_path('../dependency-graph/attribute-definer', __FILE__)

module Skylab; end

module Skylab::Face
  class DependencyGraph
    include Colors
    extend AttributeDefiner
    module TaskTypes; end
    class << self
      def build data, parent_graph
        empty_graph = new
        empty_graph.parent_graph = parent_graph
        empty_graph = empty_graph.initialize_child_graph(data)
        empty_graph
      end
    end
    def initialize nodes=nil
      @nodes = nodes
    end
    attr_reader :ui
    attr_reader :request
    attr_reader :has_parent
    alias_method :parent?, :has_parent
    def parent_graph= parent_graph
      class << self ; self end.send(:define_method, :parent_graph) { parent_graph }
      @ui = parent_graph.ui
      parent_graph.request and @request = parent_graph.request
      @has_parent = true
      parent_graph
    end
    def disabled? ; false end # for now
    def name
      @nodes and @nodes['name'] and return @nodes['name']
      debugger; 1==1
    end
    def run ui, req
      @ui = ui
      @request = req
      ok =
      if @request[:check]
        run_check
      else
        run_slake
      end
      after_run_slake_or_check ok
    end
    def run_check
      node, ret = target_node
      node or return ret
      @ui.err.puts "#{bold('---> checking:')} #{BLU name}"
      if result = node.check
        node?('version') and node('version').run
      end
      after_run_slake_or_check result
    end
    def run_slake
      node, ret = target_node
      node or return ret
      @ui.err.puts "#{bold('---> installing/checking:')} #{BLU name}"
      node.slake
    end
    def after_run_slake_or_check ok
      if ok
        @ui.err.puts "#{bold('---> installed:')} #{BLU name}"
      else
        @ui.err.puts "#{ohno('---> dependency not met:')} #{BLU name}"
      end
      ok
    end
    def target_node
      node = self.node('target') or return [nil, nil]
      if node.disabled?
        @ui.err.puts "#{hi('---> skip:')} #{blu name} (target disabled)"
        return [nil, true]
      end
      [node, nil]
    end
    protected :target_node
    def node? name
      @nodes.key? name
    end
    def node name
      @nodes.key?(name) or return failed(
        "No such node #{name.inspect}. (Have: #{@node.keys.join(', ')})")
      case (data = @nodes[name])
      when String
        ReferenceResolution.new(self, @nodes, name, data).resolve
      when Hash
        begin
          node = Task.build_task(data, self)
        rescue SpecificationError => e
          return failed(e.message)
        end
        @nodes[name] = node
      else
        data # use whatever is there per caching above
      end
    end
    def failed msg
      @ui.err.puts msg
      false
    end
  # the following are only for dependency graphs that are acting themselves as tasks.  expecting refactoring / moving!
    def slake
      run_slake
    end
    def check
      run_check
    end
  # end
  protected
    def BLU s
      style s, :bright, :cyan
    end
    def blu s
      style s, :cyan
    end
  end
end

class Skylab::Face::DependencyGraph
  class ReferenceResolution
    def initialize *a
      @graph, @nodes, @name, @referent = a
      @visited = []
    end
    def resolve
      @visited.push @name
      _resolve @referent
    end
    def _resolve name
      if @visited.include?(name)
        @graph.failed("Circular reference? #{(@visited + [name]).join(' -> ')}")
      else
        val = @nodes[name]
        if String === val
          _resolve val
        else
          @graph.node(name)
        end
      end
    end
  end
end


module Skylab::Face
  class DependencyGraph
    class SpecificationError < ::RuntimeError; end
    class << self
      def build_from_file path
        build_from_data JSON.parse(File.read(path))
      end
      def build_from_data data
        list = DependencyList.new
        data['external dependencies'].each do |dependency_data|
          if dependency_data.key?('target') # assumes it is a graph
            list.push new(dependency_data)
          else # assume it is a task
            list.push Task.build_task(dependency_data)
          end
        end
        list
      end
    end
  end
  class DependencyList < Array
    def run ui, req
      # not sure what we want here with this list we have
      map { |task_or_graph| task_or_graph.run(ui, req) }
    end
  end
end
