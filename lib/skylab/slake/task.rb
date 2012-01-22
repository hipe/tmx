require 'rake'

module Skylab ; end

module Skylab::Slake

  root = File.expand_path('..', __FILE__)
  require "#{root}/attribute-definer"
  require "#{root}/interpolate"
  require "#{root}/parenthood"


  module TaskClassMethods
    def task_type_name
       to_s.match(/([^:]+)\z/)[1].gsub(/([a-z])([A-Z])/){ "#{$1} #{$2}" }.downcase
    end
  end

  class Task < Rake::Task
    extend AttributeDefiner
    extend Interpolate
    extend TaskClassMethods
    include Parenthood
    def execute args=nil
      if @actions.empty?
        respond_to?(:slake) and @actions.push( ->(me) { me.slake } )
        @slake and @actions.push( ->(me) { @slake.call } )
      end
      super
    end
    def initialize opts=nil
      init_parenthood
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
      instance_variable_defined?('@name') and return @name
      self.class != Task and return self.class.task_type_name
      nil
    end
    attr_writer :name
    attr_writer :slake
  end
end

