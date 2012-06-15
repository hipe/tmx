require 'skylab/porcelain/attribute-definer'

module Skylab::Treemap

  class MyAttributeMeta < Hash
    def initialize sym
      @intern = sym
    end
    def label
      self[:label] || @intern.to_s.gsub('_', ' ')
    end
  end

  class API::Action
    extend Skylab::PubSub::Emitter
    extend Skylab::Porcelain::AttributeDefiner

    attribute_meta_class MyAttributeMeta

    meta_attribute :path do |name, _|
      require 'skylab/face/path-tools'
      alias_method("#{name}_after_path=", "#{name}=")
      define_method("#{name}=") do |path|
        send("#{name}_after_path=", path ? Skylab::Face::MyPathname.new(path.to_s) : path)
        path
      end
    end

    meta_attribute :regex do |name, ma|
      alias_method("#{name}_before_regex=", "#{name}=")
      define_method("#{name}=") do |val|
        if md = ma[:regex].first.match(val.to_s)
          send("#{name}_before_regex=", md[0])
        else
          add_validation_error(name, val, ma[:regex].last)
          val
        end
      end
    end

    meta_attribute :required

    def add_validation_error name, value, message
      (validation_errors[name] ||= []).push message
    end

    def attributes
      self.class.attributes
    end

    def clear!
      attributes.keys.each { |k| instance_variable_set("@#{k}", nil) }
      (@validation_errors ||= {}).clear
      self
    end

    def error s
      emit :error, s
      false
    end
    def info s
      emit :info, s
      true
    end
    def r
      @r ||= Skylab::Treemap::R::Bridge.new
    end
    def update_parameters! params
      params.each { |k, v| send("#{k}=", v) }
      self
    end
    def validate
      ok = true
      validation_errors.each do |k, errs|
        ok = error(%{#{pre attributes[k].label} #{errs.join(' and it ')}})
      end
      ok or return false # avoid superflous messages below
      if (a = attributes.select{ |n, m| m[:required] and ! send(n) }).any?
        ok = error("missing required attribute#{s a}: " <<
          "#{oxford_comma(a.map { |o| pre attributes[o.first].label }) }")
      end
      ok
    end
    attr_reader :validation_errors
    def wire!
      yield self
    end
  end
end

