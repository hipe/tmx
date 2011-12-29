require 'rake'

module Skylab ; end
module Skylab::Slake

  root = File.expand_path('..', __FILE__)
  require "#{root}/attribute-definer"
  require "#{root}/interpolate"


  module TaskClassMethods
    def task_type_name
       to_s.match(/([^:]+)\z/)[1].gsub(/([a-z])([A-Z])/){ "#{$1} #{$2}" }.downcase
    end
  end

  class Task < Rake::Task
    extend AttributeDefiner
    extend Interpolate
    extend TaskClassMethods
    def execute args=nil
      @actions.empty? and respond_to?(:slake) and @actions.push( ->(me) { me.slake } )
      super
    end
    def initialize opts=nil
      block_given? and yield self
      opts and opts.each { |k, v| send("#{k}=", v) }
      super(name, Rake.application)
    end
    meta_attribute :interpolated
    def self.on_interpolated_attribute name, meta
      if meta[:interpolated]
        define_method(name) do
          self.class.interpolate instance_variable_get("@#{name}"), self
        end
      else
        attr_reader name
      end
    end
    def name
      self.class.task_type_name
    end
  end
end

