skylab_dir = File.expand_path('../../..', __FILE__)
$:.include?(skylab_dir) or $:.unshift(skylab_dir)

require 'json'
require File.expand_path('../task', __FILE__)

module Skylab::Dependency
  class List < Array
    include Skylab::Face::Colors
    include NodeMethods

    attr_accessor :path # the path of the json file that defines this list

    extend Skylab::Slake::AttributeDefiner
    attribute :show_info, :default => true
    attribute :_child_prefix, :default => '**>>' # super ugly so you notice it
    attribute :_indent_with, :default => '**'    # ditto

    def node_type ; :list end

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
        data = { "_child_prefix" => '---> ', "_indent_with" => '--' }.merge(data)
        ed = data.delete('external dependencies') or fail("\"external dependencies\" must be present in data.")
        list = List.new(data, nil) # no parent!
        ed.each do |dependency_data|
          case dependency_data
          when String
            list.push Task.build_task( { 'build tarball' => dependency_data }, list )
          when Hash
            if dependency_data.key?('target') # assumes it is a graph.
              _data = {} # empty ass data for graph for now
              dependency_data.key?('name') and _data['name'] = dependency_data.delete('name') # ick
              graph = new(_data, list) # Graph.new (only place!)
              graph.node_data = dependency_data
              list.push graph
            else # assume it is a task
              list.push Task.build_task(dependency_data, list)
            end
          else
            raise SpecificationError.new("no: #{dependency_data.inspect}")
          end
        end
        list
      end
    end
    def node_type ; :graph end
    def node_data= data
      @nodes = data
    end
    def node_data
      @nodes
    end
    def children
      respond_to?(:_expanded_children) or require File.expand_path('../graph/children', __FILE__)
      _inflate_children
    end
    def node name
      @nodes.key?(name) or return failed(
        "No such node #{name.inspect}. (Have: #{@nodes.keys.join(', ')})")
      result = case (data = @nodes[name])
      when String
        ReferenceResolution.new(self, @nodes, name, data).resolve
      when Hash
        begin
          if ! data.key?('name') and 'target' != name # ick, experimental
            data['name'] = name
          end
          node = Task.build_task(data, self)
        rescue SpecificationError => e
          return failed(e.message)
        end
        node.task_init or return _fail("failed to initialize task")
        @nodes[name] = node
      else
        data # use whatever is there per caching above
      end
      unless result.task_init_ok
        fail("fix this, task must always be initted at this point.")
      end
      result
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
      :parent_list == @parent_accessor ? parent_list : super
    end
    def failed msg
      ui.err.puts msg
      false
    end
    def _run_filtered
      node = self.node(_ = request.delete(:name)) or return false # stop the recursion
      _info "running filtered subset: #{_.inspect}"
      node.run(ui, request) # pass the same args again
    end
  protected
    def check
      node, ret = target_node
      node or return ret
      @show_info and ui.err.puts("#{grph 'checking'}#{styled_name}")
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
      @show_info and ui.err.puts("#{grph 'checking for updates'}#{styled_name}")
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
      @show_info and ui.err.puts("#{grph 'installing/checking'}#{styled_name}")
      dependencies_slake or return false
      ok = node.slake
      after_run_slake_or_check ok
    end
    def after_run_slake_or_check ok
      if ok
        @show_info and ui.err.puts("#{grph 'installed'}#{styled_name}")
      else
        @show_info and ui.err.puts("#{ohno("#{_prefix}dependency not met:")} #{styled_name}")
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
        @show_info and ui.err.puts("#{hi("#{_prefix}skip:")} #{styled_name(:strong => false)} (target disabled)")
        return [nil, true]
      end
      [node, nil]
    end
    # a styled prefix just used by graphs for now
    def grph str
      "#{_prefix}#{bold str}: "
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
      elsif @nodes.key? name
        val = @nodes[name]
        if String === val
          if @nodes.key? val
            _resolve val
          else
            @graph.failed("no node found for #{name.inspect}")
          end
        else
          @graph.node(name)
        end
      elsif %r{\A(?:https?|ftp)://} =~ name # a bit hacked for now
        Task.build_task({ 'build tarball' => name }, @graph)
      else
        @graph.failed("nope: #{name.inspect}")
      end
    end
  end
end
