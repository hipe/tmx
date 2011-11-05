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
      'mkdir p',
      'move to',
      'symlink',
      'tarball to',
      'unzip tarball',
      'version from'
    ]
    class << self
      def identifying_keys_in keys
        found = IdentifyingKeys & keys
        ['get', 'tarball to'] == found and found.shift # sorry
        found
      end
      def build_task data, graph
        found = identifying_keys_in data.keys
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
        task.task_init or return false # experimental, not guaranteed to happen here
        task.valid? or return false
        task
      end
      def _fail msg
        raise SpecificationError.new(msg)
      end
      def looks_like_task? t
        t.respond_to?(:name) and t.respond_to?(:children)
      end
    end
    def _fail msg
      raise SpecificationError.new(msg)
    end
    def _err msg
      ui.err.puts "#{_prefix}#{me}: #{ohno('error:')} #{msg}"
      false
    end
    def _info msg
      ui.err.puts "#{_prefix}#{me}: #{msg}"
      true
    end
    def _prefix
      @_prefix and return @_prefix
      @has_parent or return '  * '
      _parent._child_prefix
    end
    def _indent_with
      @_indent_with and return @_indent_with
      @has_parent or return ' '
      _parent._indent_with
    end
    def _child_prefix
      @_child_prefix and return @_child_prefix
      "#{_indent_with}#{_prefix}"
    end
    def _parent
      send @parent_accessor
    end
    # it's important we do do some class-specific initialization so that we can have readable
    # child class initialize methods who rely on this and e.g. the parent and ui and etc.
    def initialize data, parent_graph
      if parent_graph
        meet_parent_graph parent_graph
        _inherit_attributes_from_parent_graph! data
      end
      update_attributes data
    end
    alias_method :task_orig_initialize, :initialize

    def styled_name opts=nil
      style = if opts
        if    false == opts[:color]  then :_no_color
        elsif false == opts[:strong] then :blu
        else                              :BLU end
      else                                :blu end
      if @name
        return "#{send(style, @name)} (#{task_type_name})"
      end
      if main_attribute = instance_variable_get("@#{task_type_name.gsub(' ', '_')}")
        return "#{task_type_name}: #{send(style, main_attribute)}"
      end
      send(style, task_type_name)
    end

    def ui
      @ui || parent_graph.ui
    end
    def request
      @request || parent_graph.request
    end
    def task_init
      @task_initted ||= begin
        @task_init_ok = _task_init
        true
      end
      @task_init_ok
    end
    def _task_init
      defaults!
      interpolated? or interpolate! or false
    end
    def defaults!
      ret = @did_defaults
      @did_defaults ||= begin
        _defaults!
        true
      end
      ret ? nil : true
    end
    def _defaults!
    end
    # @experimental
    def _closest_parent_list
      parent_graph and parent_graph._closest_parent_list
    end
    def run ui, req
      @ui = ui
      @request = req
      if ! task_init
        false
      elsif @request[:check]
        if @request[:update]
          update_check
        else
          check
        end
      elsif @request[:view_tree]
        _view_tree
      else
        if @request[:update]
          update_slake
        else
          slake
        end
      end
    end
    def _view_tree
      require 'skylab/face/cli/view/tree'
      loc = Skylab::Face::Cli::View::Tree::Locus.new
      color = ui.out.tty?
      loc.traverse(self) do |node, meta|
        ui.out.puts "#{loc.prefix(meta)}#{node.styled_name(:color => color)} (#{node.object_id.to_s(16)})"
      end
    end
    def update_check
      _skip "no update_check defined for #{blu name}"
    end
    def update_slake
      _skip "no update_slake defined for #{blue name}"
    end
    def _with_dependencies meth
      @requires.nil? and return true
      (@requires.kind_of?(Array) ? @requires : [@requires]).each do |req|
        parent_graph.node(req).send(meth) or return false
      end
      true
    end
    def dependencies_update_check
      _with_dependencies :update_check
    end
    def dependencies_slake
      _with_dependencies :slake
    end
    def build_dir
      @build_dir ||= begin
        request[:build_dir] or fail("request does not specify :build_dir")
      end
    end
    def interpolate_build_dir
      build_dir
    end
    def BLU s
      style s, :bright, :cyan
    end
    def blu s
      style s, :cyan
    end
    def _no_color x ; x end
    def _skip msg
      ui.err.puts "#{hi '---> skip:'} #{blu name}: #{msg}"
      false
    end
  end
end

