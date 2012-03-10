require File.expand_path('../..', __FILE__)
require 'skylab/porcelain/bleeding'
require 'skylab/slake/attribute-definer'
require 'skylab/face/path-tools'
require 'stringio' # whaetver
require 'skylab/test-support/test-support' # ick just for deindent

module Skylab::Asib
  include Skylab::Porcelain::Bleeding
  Action = Action; #!

  class Cli < Runtime
  end

  module Actions
  end


  #### "model" and utility classes and support

  class MyPathname < Pathname
    def pretty
      Skylab::Face::PathTools.pretty_path to_s
    end
  end


  #### "action" base class

  class MyAction
    extend Action
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

  class Actions::Put < MyAction
    desc "put the file"
    desc "(see config-make)"
    def execute path
      emit :info, "ok, sure: #{path}"
    end
  end

  class Actions::ConfigMake < MyAction

    desc "write the config file"

    attribute :dest, :pathname => true, :default => ->() { "#{ENV['HOME']}/.asibrc" }
    attribute :dry_run, :boolean => true, :default => false
    alias_method :dry?, :dry_run?

    option_syntax do |h|
      on('-n', '--dry-run', "dry run.") { h[:dry_run] = true }
    end

    def execute opts
      update_attributes! opts
      dest.exist? and return skip("already exists: #{dest.pretty}")
      dest.open('w+') do |fh|
        content = <<-HERE.unindent
          host = yourhost
          document_root = /path/to/your/doc/root
        HERE
        b = dry? ? nil : fh.write(content)
        emit :info, "wrote #{dest.pretty} (#{b} bytes)"
      end
      true
    end
  end
end

