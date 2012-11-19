require 'rake' # for fun and as an implementation detail we use it

module Skylab::Slake

  module TaskClassMethods
    def task_type_name
       to_s.match(/([^:]+)\z/)[1].gsub(/([a-z])([A-Z])/){ "#{$1} #{$2}" }.downcase
    end
  end

  class Task < ::Rake::Task
    extend Skylab::Porcelain::Attribute::Definer
    extend Slake::Interpolate
    extend TaskClassMethods
    include Slake::Parenthood
    def action= action
      @actions.push action
    end
    def initialize opts=nil
      init_parenthood
      block_given? and yield self
      if opts
        opts = opts.dup
        opts.key?(:name) and self.name = opts.delete(:name)
      end
      super(name, rake_application) # nil name ok, we need things from above
      opts and opts.each { |k, v| send("#{k}=", v) }
      @arg_names ||= [:context] # a resonable, harmless default
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
    def name= name
      name = name.to_s # per rake
      @name == name and return name # noop
      @name.nil? or @name == '' or fail("for now, won't clobber existing names (#{name.inspect} on top of #{@name.inspect})")
      @name = name
    end
    def prerequisites= arr
      @prerequisites.any? and raise RuntimeError.new("prerequisites= cannot be used to overwrite nor concat to any existing prereqs")
      @prerequisites.concat arr
      arr
    end
    def rake_application
      ::Rake.application
    end
  end
end
