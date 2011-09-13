require 'skylab/slake/task'

module Skylab::Dependency
  class SpecificationError < ::Skylab::Slake::SpecificationError; end
  module TaskTypes
    # loaded as necessary by logic in this file
  end
  class Task < Skylab::Slake::Task
    attribute :requires, :required => false
    IdentifyingKeys = [ # we could of course generate these but we leave it explicit for now
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
          TaskTypes.const_get(klass).build_specific_task(data, graph)
        else
          _fail("Ambiguous, mutually exclusive keys: (#{found.join(', ')})")
        end
      end
      def build_specific_task data, parent_graph
        self == ::Skylab::Dependency::Task and fail("This is not to be called directly, but only from task subclasses")
        task = new(data, parent_graph)
        task.valid? or return false
        task
      end
      def _fail msg
        raise SpecificationError.new(msg)
      end
    end
    def _fail msg
      raise SpecificationError.new(msg)
    end
    # it's important we do do some class-specific initialization so that we can have readable
    # child class initialize methods who rely on this and e.g. the parent and ui and etc.
    def initialize data, parent_graph
      parent_graph and self.parent_graph = parent_graph
      update_attributes data
    end
    def parent_graph= parent_graph
      class << self ; self end.send(:define_method, :parent_graph) { parent_graph }
      @has_parent = true
      parent_graph
    end
    def ui
      @ui || parent_graph.ui
    end
    def request
      @request || parent_graph.request
    end
    def before_check_or_slake
      interpolated? or interpolate! or return false
      true
    end
    def run ui, req
      @ui = ui
      @request = req
      ok =
      if @request[:check]
        check
      else
        slake
      end
    end
    def build_dir
      @build_dir ||= begin
        request[:build_dir] or fail("request does not specify :build_dir")
      end
    end
  end
end