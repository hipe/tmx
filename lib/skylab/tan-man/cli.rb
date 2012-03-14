require File.expand_path('../..', __FILE__)
require 'skylab/code-molester/config/file'
require 'skylab/face/path-tools'
require 'skylab/porcelain/bleeding'
require 'skylab/slake/attribute-definer'
require 'skylab/test-support/test-support' # ick just for unindent

module Skylab::Asib
  Bleeding = Skylab::Porcelain::Bleeding

  class Cli < Bleeding::Runtime
  end

  module Actions
  end

  class MyPathname < Pathname
    def pretty
      Skylab::Face::PathTools.pretty_path to_s
    end
  end

  CONF_PATH = ->() { "#{ENV['HOME']}/.asibrc" }

  class Config < Skylab::CodeMolester::Config::File
    extend Skylab::Slake::AttributeDefiner



  end

  module ConfigMethods
    attr_reader :config
    def config?
      @config ||= build_config { |o| o.on_all { |s| emit(:stderr, s) } }
      !! @config
    end
    OnLoadConfig = Skylab::PubSub::Emitter.new(:all, :error => :all)
    def build_config
      yield(on = OnLoadConfig.new)
      conf = Skylab::CodeMolester::Config::File.new(:path => CONF_PATH.call)
      unless conf.exist?
        on.emit(:error, "Config file not found. Expecting #{conf.pretty}. Try #{pre "#{runtime.program_name} config generate"}")
        return false
      end
      if ! conf.valid?
        on.emit(:error, "issue with #{conf.pretty}: #{conf.invalid_reason}")
        return false
      end
      conf
    end
    def config_init
      @config = nil
    end
  end

  class MyAction
    extend Bleeding::Action
    extend ::Skylab::Slake::AttributeDefiner
    include ConfigMethods

    def self.inherited cls
      cls.action_module_init
    end

    meta_attribute :boolean
    def self.on_boolean_attribute name, _
      alias_method "#{name}?", name
    end

    meta_attribute :default

    meta_attribute :pathname
    def self.on_pathname_attribute name, _
      alias_method "#{name}_before_pathname=", "#{name}="
      define_method("#{name}=") do |path|
        send("#{name}_before_pathname=", MyPathname.new(path.to_s))
      end
    end

    def initialize *a
      action_init(*a)
      config_init
      self.class.attributes.select { |k, v| v.key?(:default) }.each do |k, v|
        send("#{k}=", v[:default].respond_to?(:call) ? v[:default].call : v[:default])
      end
    end

    def skip m
      emit(:info, "#{m}, skipping")
      nil
    end

    def update_attributes! req
      req.each { |k, v| send("#{k}=", v) }
    end
  end


  #### "actions"
  #
  module Actions; end

  class Actions::Put < MyAction
    desc "put files to remote server (see config-make)"
    option_syntax do |h|
      on('-n', '--dry-run', "Dry run.") { h[:dry_run] = true }
    end
    def execute path
      config? or return false


      emit :info, "ok, sure: #{config.path}"
    end
  end

  module Actions::Config
    extend Bleeding::Namespace
    desc "manage the config file"
    summary { ["config file stuff (child actions: #{action_syntax})"] }
  end

  class Actions::Config::Generate < MyAction

    desc "write the config file"

    attribute :dest, :pathname => true, :default => CONF_PATH
    attribute :dry_run, :boolean => true, :default => false

    option_syntax do |h|
      on('-n', '--dry-run', "dry run.") { h[:dry_run] = true }
    end

    def execute opts
      update_attributes! opts
      content = <<-HERE.unindent
        host = yourhost
        document_root = /path/to/your/doc/root
      HERE
      if dest.exist?
        if content == dest.read
          return skip("no change: #{dest.pretty}")
        else
          return skip("exists, won't overwrite: #{dest.pretty}")
        end
      end
      bytes = 0
      dest.open('w+') { |fh| bytes = fh.write(content) } unless dry_run?
      emit :info, "wrote #{dest.pretty} (#{bytes} bytes)"
      true
    end
  end
end

