require File.expand_path('../../face/cli', __FILE__) # Colors
require File.expand_path('../interpolation', __FILE__)
require File.expand_path('../attribute-definer', __FILE__)

module Skylab
  module Slake
    class Task
      include Face::Colors
      include Interpolation
      extend AttributeDefiner
      TarballExtension = /(?:\.tar\.gz|\.tgz)\z/
      class << self
        def build data, graph
          task = new(graph)
          task.update_attributes(data)
          task.valid? or return false
          task
        end
      end

      attribute :enabled, :required => false

      def initialize graph
        class << self; self end.send(:define_method, 'parent_graph') { graph }
        @ui = parent_graph.ui
      end
      attr_accessor :else
      alias_method :deps?, :else
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
          @ui.err.puts("#{task_type_name} is missing required #{missing.map(&:inspect).join(' and ')} field(s).")
          return false
        end
        true
      end
      def task_type_name
        self.class.to_s.match(/([^:]+)\z/)[1].gsub(/([a-z])([A-Z])/){ "#{$1} #{$2}" }.downcase
      end
      alias_method :name, :task_type_name # experimental
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
        @ui.err.puts("#{ohno('dead end:')} Sorry, there are no supporting tasks "<<
          " to help with #{task_type_name.inspect}.")
        false
      end
      def nope message
        @ui.err.puts("#{me}: #{ohno('failed:')} #{message}")
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

class Skylab::Face::DependencyGraph
  class Task
    IdentifyingKeys = [
      'ad hoc',
      'build tarball',
      'configure make make install',
      'get',
      'executable',
      'executable file',
      'move to',
      'symlink',
      'tarball to',
      'unzip tarball',
      'version from'
    ]
    class << self
      def build_task data, graph
        found = IdentifyingKeys & data.keys
        ['get', 'tarball to'] == found and found.shift # sorry
        case found.length
        when 0
          _fail("Needed one had zero of " <<
            "(#{IdentifyingKeys.join(', ')}) among (#{data.keys.join(', ')})")
        when 1
          identifier = found.first
          require File.expand_path("../task-types/#{identifier.gsub(' ','-')}", __FILE__)
          klass = identifier.capitalize.gsub(/ ([a-z])/){ $1.upcase }.to_sym
          TaskTypes.const_get(klass).build(data, graph)
        else
          _fail("Ambiguous, mutually exclusive keys: (#{found.join(', ')})")
        end
      end
      def _fail msg
        raise SpecificationError.new(msg)
      end
    end
  end
end
