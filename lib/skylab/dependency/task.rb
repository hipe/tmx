require 'skylab/slake/task'
require File.expand_path('../node-methods', __FILE__)

module Skylab::Dependency
  class SpecificationError < ::Skylab::Slake::SpecificationError; end
  module TaskTypes
    # loaded as necessary by logic in this file
  end
  class Task < Skylab::Slake::Task
    attribute :requires, :required => false
    attribute :show_info, :required => false, :default => true
    attribute :inherit_attributes, :reqiured => false, :default => ['show info']

    include NodeMethods

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
      def build_specific_task data, parent
        self == ::Skylab::Dependency::Task and fail("This is not to be called directly, but only from task subclasses")
        task = new(data, parent)
        task.required_attributes_present? or return false
        task.task_init or return false # experimental, not guaranteed to happen here
        task
      end
      def _fail msg
        raise SpecificationError.new(msg)
      end
      def looks_like_task? t
        t.respond_to?(:name) and t.respond_to?(:children)
      end
    end
    def node_type ; :task end
    def _fail msg
      raise SpecificationError.new(msg)
    end
    def _err msg
      ui.err.puts "#{_prefix}#{me}: #{ohno('error:')} #{msg}"
      false
    end
    def _info msg
      @show_info and ui.err.puts "#{_prefix}#{me}: #{msg}"
      true
    end
    def _pretending msg, path=nil
      if @show_info
        _msg = "#{yelo 'pretending'} #{msg} for dry run"
        path and (_msg << ": #{pretty_path path}")
        _info _msg
      end
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
    PERMITTED_PARENTS = {
      :list  => [],
      :graph => [:list, :graph],
      :task  => [:graph]
    }
    def meet_parent parent, data
      @has_parent and fail("can't add multiple parents")
      @has_parent = true
      PERMITTED_PARENTS[node_type].include?(parent.node_type) or fail("nope")
      @parent_accessor = case parent.node_type
                         when :graph ; :parent_graph
                         when :list  ; :parent_list
                         else        ; fail("nope: #{parent.node_type.inspect}") ; end
      class << self ; self end.send(:define_method, @parent_accessor) { parent }
      data.key?(:inherit_attributes) and update_attributes(:inherit_attributes => data[:inherit_attributes])
      _inherit_attributes_from_parent! data
      data.delete(:inherit_attributes)
      self
    end
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
    attr_accessor :task_initted, :task_init_ok # debugging only
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

    MutexOpts = [:check, :update, :view_tree, :view_bash]
    def run ui, req
      @ui = ui
      @request = req
      task_init or return false
      @request[:name] and return _run_filtered
      1 < (ks = (req.keys & MutexOpts)).size && (ks2 = (ks - [:check, :update])).any? and return _mutex_fail(ks, ks2)
      (a = (ks2 or ks)).any? and return case a.first
        when :view_tree ; _view_tree
        when :view_bash ; _view_bash
      end
      if @request[:check]
        if @request[:update]
          update_check
        else
          check
        end
      elsif @request[:update]
        update_slake
      else
        slake
      end
    end
    def _mutex_fail ks, ks2
      ks.length > ks2.length and ks2.push('("check" and or "update")')
      ks2.map! { |e| e.kind_of?(String) ? e : "\"#{e.to_s.gsub('_', ' ')}\"" }
      _err "#{ks2.join(' and ')} are mutually exclusive.  Please use only one."
      false
    end
    def dry_run?            ; request[:dry_run]            end
    def optimistic_dry_run? ; request[:optimistic_dry_run] end
    def _view_tree
      require 'skylab/face/cli/view/tree'
      loc = Skylab::Face::Cli::View::Tree::Locus.new
      color = ui.out.tty?
      loc.traverse(self) do |node, meta|
        ui.out.puts "#{loc.prefix(meta)}#{node.styled_name(:color => color)} (#{node.object_id.to_s(16)})"
      end
    end
    def _view_bash
      @request[:dry_run] = true
      @request[:optimistic_dry_run] = true
      @show_info = false
      slake
    end
    def _show_bash cmd
      if request[:view_bash]
        ui.out.puts cmd
      else
        _info cmd
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
    # BEGIN styles (abbreviated b/c of frequency of use)
    def BLU s
      style s, :bright, :cyan
    end
    def blu s
      style s, :cyan
    end
    def skp s
      style s, :bright, :white
    end
    # end
    def _no_color x ; x end
    def _skip msg
      ui.err.puts "#{hi '---> skip:'} #{blu name}: #{msg}"
      false
    end
  end
end

