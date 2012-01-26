require 'skylab/slake/task'
require 'skylab/slake/muxer'
require 'skylab/face/path-tools'
require 'skylab/porcelain/tite-color'

module Skylab::Dependency

  class Task < Skylab::Slake::Task
    meta_attribute :boolean
    meta_attribute :default
    meta_attribute :from_context
    meta_attribute :required

    attr_accessor  :context
    attr_reader :invalid_reason

    extend ::Skylab::Slake::Muxer # child classes decide what to emit
    include ::Skylab::Face::PathTools
    include ::Skylab::Porcelain::TiteColor

    def hi str ; stylize str, :strong, :green end
    def no str ; stylize str, :strong, :red   end

    def initialize(*)
      super
      event_listeners[:all] ||= [lambda { |e| $stdout.puts e }]
    end

    def valid?
      reqd = self.class.attributes.to_a.select{ |k, v| v[:required] }.map(&:first)
      nope = reqd.select { |r| send(r).nil? }
      if nope.any?
        @invalid_reason = "#{name} task missing required attribute#{'s' if nope.length != 1}: #{nope.join(', ')}"
        return false
      end
      true
    end
  end

  class << Task
    def on_boolean_attribute name, meta
      define_method("#{name}?") { send(name) } # alias_method misses future hacks
    end
    def on_default_attribute name, meta
      alias_method "#{name}_before_default", name
      define_method(name) do
        v = send("#{name}_before_default")
        v.nil? or return v
        meta[:default]
      end
    end
    def on_from_context_attribute name, meta
      alias_method "#{name}_before_from_context", name
      define_method(name) do
        if instance_variable_defined?("@#{name}") # verrry experimental
          return instance_variable_get("@#{name}")
        end
        if @context.key?(name)
          return @context[name]
        end
        send "#{name}_before_from_context"
      end
    end
  end
end

