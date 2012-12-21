require 'skylab/slake/attribute-definer'

module Skylab::GitViz
  class Api::Action < Struct.new(:api, :params)
    extend ::Skylab::Slake::AttributeDefiner
    meta_attribute :pathname
    meta_attribute :default
    def emit(*a)
      api.runtime.emit(*a)
    end
    def initialize api, params
      super(api, params)
      self.class.defaults.each { |k, v| send("#{k}=", v) }
    end
  end
  class << Api::Action
    attr_reader :defaults
    def inherited mod
      mod.instance_variable_set('@defaults', {})
    end
    def on_default_attribute name, meta
      defaults[name] = meta[:default]
    end
    def on_pathname_attribute name, meta
      alias_method("#{name}_after_pathname=", "#{name}=")
      define_method("#{name}=") do |p|
        send("#{name}_after_pathname=", (p ? Pathname.new(p) : nil))
      end
    end
  end
end

