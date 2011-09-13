skylab_dir = File.expand_path('../../..', __FILE__)
$:.include?(skylab_dir) or $:.unshift(skylab_dir)

require File.expand_path('../task', __FILE__)

module Skylab::Dependency
  class List < Array
    def run ui, req
      # not sure what we want here with this list we have
      map { |task_or_graph| task_or_graph.run(ui, req) }
    end
  end
  class Graph < Task
    class << self
      def from_file path
        from_data JSON.parse(File.read(path))
      end
      def from_data data
        list = List.new
        data['external dependencies'].each do |dependency_data|
          case dependency_data
          when String
            $stdout.puts "skpping for now: #{dependency_data}"
          when Hash
            if dependency_data.key?('target') # assumes it is a graph
              graph = new
              dependency_data.key?('name') and graph.name = dependency_data['name']
              graph.node_data = dependency_data
              list.push graph
            else # assume it is a task
              list.push Task.build_task(dependency_data, nil)
            end
          else
            raise SpecificationError.new("no: #{dependency_data.inspect}")
          end
        end
        list
      end
    end
    def initialize
      # override parent, we want no args
    end
    attr_reader :ui # override parent, graphs maintain their own ui attribute
    attr_reader :request # same as above
    def node_data= data
      @nodes = data
    end
    def node_data
      @nodes
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
    def node? name
      @nodes.key? name
    end
  protected
    def failed msg
      ui.err.puts msg
      false
    end
    def check
      node, ret = target_node
      node or return ret
      ui.err.puts "#{bold('---> checking:')} #{BLU name}"
      if ok = node.before_check_or_slake
        if ok = node.check
          node?('version') and node('version').run
        end
      end
      after_run_slake_or_check ok
    end
    def slake
      node, ret = target_node
      node or return ret
      ui.err.puts "#{bold('---> installing/checking:')} #{BLU name}"
      ok = node.before_check_or_slake and ok = node.slake
      after_run_slake_or_check ok
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
        ui.err.puts "#{hi('---> skip:')} #{blu name} (target disabled)"
        return [nil, true]
      end
      [node, nil]
    end
    def BLU s
      style s, :bright, :cyan
    end
    def blu s
      style s, :cyan
    end
  end
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
  class SpecificationError < ::RuntimeError; end
end
