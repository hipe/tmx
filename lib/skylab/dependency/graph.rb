skylab_dir = File.expand_path('../../..', __FILE__)
$:.include?(skylab_dir) or $:.unshift(skylab_dir)

require 'json'
require File.expand_path('../task', __FILE__)

module Skylab::Dependency
  class List < Array
    include Skylab::Face::Colors
    attr_accessor :path # the path of the json file that defines this list
    def initialize opts=nil
      super()
      opts and opts.each { |k, v| send("#{k}=", v) }
      @_child_prefix ||= '**>>' # some super ugly defaults so you notice
      @_indent_with  ||= '**'
    end
    attr_accessor :_child_prefix, :_indent_with
    def run ui, req
      results = []
      last_node = last_index = nil
      begin
        # not sure what we want here with this list we have
        each_with_index do |task_or_graph, index|
          last_index = index
          last_node = task_or_graph
          results.push task_or_graph.run(ui, req)
        end
      rescue Interrupt => e
        ui.err.puts("\nReceived INT signal while processing item " <<
          "#{last_index + 1}/#{size}: #{hi last_node.name}.  Exiting early.  Goodbye!")
        last_node.undo
      end
      results
    end
  end
  class Graph < Task
    class << self
      def from_file path
        dep_list = from_data JSON.parse(File.read(path))
        dep_list and dep_list.path = path
        dep_list
      end
      def from_data data
        list = List.new(:_child_prefix => '--->', :_indent_with => '--')
        data['external dependencies'].each do |dependency_data|
          case dependency_data
          when String
            list.push Task.build_task({'get' => dependency_data}, nil).meet_parent_list(list)
          when Hash
            if dependency_data.key?('target') # assumes it is a graph
              graph = new
              dependency_data.key?('name') and graph.name = dependency_data['name']
              graph.node_data = dependency_data
              list.push graph.meet_parent_list(list)
            else # assume it is a task
              list.push Task.build_task(dependency_data, nil).meet_parent_list(list)
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
    def meet_parent_list list
      @has_parent and fail("can't assign multiple parents")
      class << self ; self end.send(:define_method, :parent_list) { list }
      @has_parent = true
      @parent_accessor = :parent_list
      self
    end
    def node_data= data
      @nodes = data
    end
    def node_data
      @nodes
    end
    def children
      @nodes.map do |k, v|
        case v
        when String ; # either a property or a reference.  if reference, meh
        when Hash
          if 1 == Task.identifying_keys_in(v.keys).size
            node(k)
          end
        else
          if Task.looks_like_task?(v)
            v
          end
        end
      end.compact
    end
    def node name
      @nodes.key?(name) or return failed(
        "No such node #{name.inspect}. (Have: #{@nodes.keys.join(', ')})")
      case (data = @nodes[name])
      when String
        ReferenceResolution.new(self, @nodes, name, data).resolve
      when Hash
        begin
          node = Task.build_task(data, self)
        rescue SpecificationError => e
          return failed(e.message)
        end
        node.task_init or return _fail("failed to initialize task")
        @nodes[name] = node
      else
        data # use whatever is there per caching above
      end
    end
    def node? name
      @nodes.key? name
    end
    def undo
      node, ret = target_node
      node or return super
      node.undo
    end
    def _closest_parent_list
      _ = _parent_list and return _
      super
    end
  protected
    def failed msg
      ui.err.puts msg
      false
    end
    def check
      node, ret = target_node
      node or return ret
      ui.err.puts "#{bold('---> checking:')} #{styled_name}"
      if ok = node.check
        node?('version') and node('version').run
      end
      after_run_slake_or_check ok
    end
    def update_check
      node = _checking_for_updates or return false
      node.update_check
    end
    def update_slake
      node = _checking_for_updates or return false
      node.update_slake
    end
    def _checking_for_updates
      ui.err.puts "#{bold '---> checking for updates:'} #{styled_name}"
      node, ret = target_node
      if ! node
        _skip("no updates to perform for #{styled_name(:strong => false)} because no target_node " <<
          "found and update_{check|slake} not defined for task type.")
        return false
      end
      node
    end
    def slake
      node, ret = target_node
      node or return ret
      ui.err.puts "#{bold('---> installing/checking:')} #{styled_name}"
      dependencies_slake or return false
      ok = node.slake
      after_run_slake_or_check ok
    end
    def after_run_slake_or_check ok
      if ok
        ui.err.puts "#{bold('---> installed:')} #{styled_name}"
      else
        ui.err.puts "#{ohno('---> dependency not met:')} #{styled_name}"
      end
      ok
    end
    def target_node
      if @nodes.nil?
        _skip "can't get target node of #{styled_name(:strong => false)}: there are no child nodes defined."
        return [nil, false]
      end
      node = self.node('target') or return [nil, nil]
      if node.disabled?
        ui.err.puts "#{hi('---> skip:')} #{style_name(:strong => false)} (target disabled)"
        return [nil, true]
      end
      [node, nil]
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
end
