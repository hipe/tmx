require File.expand_path('../open2', __FILE__)
require File.expand_path('../path-tools', __FILE__)

module Skylab; end

module Skylab::Face
  class DependencyGraph
    include Colors
    module TaskTypes; end
    class << self
      def run(*a) ; new(*a).run  end
    end
    def initialize(*a)
      @ui, @nodes, @prefix = a
      @name = @nodes['name'].kind_of?(String) ? @nodes['name'] : 'dependency graph'
    end
    attr_reader :ui
    attr_reader :name
    def run
      node = self.node('target') or return
      @ui.err.puts "#{bold('---> installing/checking:')} #{BLU(@name)}"
      if ok = node.slake
        @ui.err.puts "#{bold('---> installed:')} #{BLU(@name)}"
        ok
      else
        @ui.err.puts "#{bold('---> not installed:')} #{BLUE(@name)}"
      end
    end
    def node name
      @nodes.key?(name) or return failed(
        "No such node #{name.inspect}. (Have: #{@node.keys.join(', ')})")
      if (node = @nodes[name]).kind_of? Hash
        node = build_node(node) or return false
        @nodes[name] = node
      end
      node
    end
    IdentifyingKeys = [
      'executable file',
      'move to',
      'symlink',
      'tarball to',
      'unzip tarball'
    ]
  protected
    def build_node node
      case (found = IdentifyingKeys & node.keys).length
      when 0
        failed("Needed one had zero of " <<
          "(#{IdentifyingKeys.join(', ')}) among (#{node.keys.join(', ')})")
      when 1
        _build_node found.first, node
      else
        failed("Ambiguous, mutually exclusive keys: (#{found.join(', ')})")
      end
    end
    def _build_node identifier, node
      require File.expand_path("../dependency-graph/task-types/#{identifier.gsub(' ','-')}", __FILE__)
      _klass = identifier.capitalize.gsub(/ ([a-z])/){ $1.upcase }.to_sym
      TaskTypes.const_get(_klass).build(self, node)
    end
    def failed msg
      @ui.err.puts msg
      false
    end
    def BLU s
      style s, :bright, :cyan
    end
  end
end
