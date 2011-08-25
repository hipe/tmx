require 'fileutils'
require 'json'
require File.expand_path('../../path-tools', __FILE__)

module Skylab::Face::ExternalDependencies

  module DefinerMethods
    def external_dependencies *a, &b
      a.any? && b and raise ArgumentError.new("Cannot take both args and block.")
      a.empty? && b.nil? and return @external_dependencies
      @external_dependencies ||= Skylab::Face::ExternalDependencies::Definition.new(self)
      if a.any?
        case a.length;
        when 1 ; @external_dependencies.add_path a.first
        else   ; raise ArgumentError.new("can only take 1 path")
        end
      else
        data = b.call
        @external_dependencies.add_data data
      end
    end
  end

  module InstanceMethods
    def external_dependencies
      @external_dependencies ||= begin
        interface.external_dependencies.for_run(self)
      end
    end
  end
end

module Skylab::Face
  class Command::Namespace
    extend ExternalDependencies::DefinerMethods
    include ExternalDependencies::InstanceMethods
  end
end

module Skylab::Face::ExternalDependencies
  module Filey
    def beautify_path path
      path.sub(/\A#{
        Regexp.escape(FileUtils.pwd.sub(/\A\/private\//, '/'))
      }/, '.')
    end
  end
  class Definition
    include Skylab::Face::Colors, Filey

    def initialize app_class
      @app_class = app_class
    end
    attr_reader :ui
    def add_to_system_job_queue cmd
      @job_queue ||= []
      @job_queue.push cmd
    end
    def add_path path
      @path and fail("multiple paths not yet implemented.")
      @path = path
      @initted_ui ||= _init_ui
    end
    def add_data data
      @config and fail("multiple datas not yet implemented.")
      @config = data
      @initted_ui ||= _init_ui
    end
    def _init_ui
      @app_class.class_eval do
        namespace(:install) do
          o { |o| o.banner = "check if external dependencies are installed" }
          def check req
            @parent.external_dependencies.check req
          end
          o { |o| o.banner = "install the dependencies" }
          def install req
            @parent.external_dependencies.install req
          end
        end
      end
    end
    def build_dir
      @build_dir ||= begin
        _dir = config.key?('build directory') ? config['build directory'] : './build'
        _dir.sub!(%r{\A~/}, "#{ENV['HOME']}/")
        unless '/' == _dir[0, 1]
          if @path
            _dir = File.expand_path(File.join(File.dirname(@path), _dir))
          end
        end
        beautify_path _dir
      end
    end
    def check req
      _ :check, req
    end
    def install req
      File.exist?(build_dir) or
        return @ui.err.puts("#{yelo('no:')} " <<
          "build dir does not exist, please create: #{build_dir}" )
      _ :install, req
    end
    def _ meth, req
      dependencies.each { |dep| dep.send(meth, req) }
      if dependencies.any?
        @ui.err.puts "(done checking #{dependencies.length} dependencies.)"
      else
        @ui.err.puts "(no dependencies in #{@path})"
      end
      if @job_queue && @job_queue.any?
        @ui.err.puts "#{style('running', :cyan)} #{@job_queue.length} jobs.."
        exec(@job_queue.join(";\n"))
      end
    end
    def config
      @config ||= JSON.parse(File.read(@path))
    end
    def dependencies
      @dependencies || begin
        @dependencies = []
        load_deps_in_array config['external dependencies']
        @dependencies
      end
    end
    def for_run ui
      @ui = ui
      self # careful
    end

  private
    def load_deps_in_array ary, prefix = nil
      ary.each do |node|
        case node
        when Hash;   load_deps_in_hash   node, prefix
        when String; load_deps_in_string node, prefix
        else
          fail("unexpected node class in dependencies: #{node.class}")
        end
      end
    end
    def load_deps_in_hash node, prefix
      unless node.key?('from') and node.key?('get')
        fail("bad signature for node: (#{node.keys.sort * ', '})")
      end
      _prefix = File.join( * [prefix, node['from']].compact )
      load_deps_in_array node['get'], _prefix
    end
    def load_deps_in_string node, prefix
      @dependencies.push(
        Dependency.new(self, :head => prefix, :tail => node )
      )
    end
  end

  class Dependency
    include Skylab::Face::Colors
    include Skylab::Face::PathTools

    alias_method :_, :escape_path

    def initialize group, mixed
      @group = group
      @ui = group.ui
      (mixed.key?(:head) and mixed.key?(:tail)) or
        fail("for now need head and tail")
      if mixed[:head].nil?
        @head = File.dirname(mixed[:tail])
        @tail = File.basename(mixed[:tail])
      else
        @head = mixed[:head]
        @tail = mixed[:tail]
      end
    end
    attr_reader :path
    def build_dir
      @group.build_dir
    end
    def build_path
      File.join(build_dir, @tail)
    end
    def unzipped_path_guess
      if /(?:\.tar\.gz|\.tgz)\z/ =~ @tail
        File.join(build_dir, @tail.sub(/(?:\.tar\.gz|\.tgz)\z/, ''))
      end
    end
    def url
      File.join( * [@head, @tail].compact )
    end
    def check req
      if File.exists? build_path
        @ui.err.puts "#{hi('exists:')} #{build_path}"
        false
      else
        @ui.err.puts "#{yelo('not installed:')} #{build_path}"
        true
      end
    end
    def install req
      if File.exists?(build_path) && 0 != File.size(build_path)
        @ui.err.puts "#{yelo('exists:')} #{build_path}"
      else
        @group.add_to_system_job_queue "wget -O #{_ build_path} #{url}"
      end
      if unzippy = unzipped_path_guess
        if File.exists?(unzippy)
          @ui.err.puts "#{yelo('exists:')} #{unzippy}"
        else
          @group.add_to_system_job_queue "cd #{_ build_dir}; tar -xzvf #{_ @tail}"
        end
      end
    end
  end
end
