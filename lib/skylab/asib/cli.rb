require File.expand_path('../..', __FILE__)
require 'skylab/porcelain/bleeding'
require 'skylab/slake/attribute-definer'
require 'skylab/face/path-tools'
require 'stringio' # whaetver
require 'skylab/test-support/test-support' # ick just for deindent

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

  class MyAction
    extend Bleeding::Action
    extend ::Skylab::Slake::AttributeDefiner

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
    desc "put the file"
    desc "(see config-make)"
    def execute path
      emit :info, "ok, sure: #{path}"
    end
  end

  module Actions::Config
    extend Bleeding::Namespace
    desc "manage the config file"
    summary { ["config file stuff (child actions: #{action_syntax})"] }
  end

  class Actions::Config::Generate < MyAction

    desc "write the config file"

    attribute :dest, :pathname => true, :default => ->() { "#{ENV['HOME']}/.asibrc" }
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

