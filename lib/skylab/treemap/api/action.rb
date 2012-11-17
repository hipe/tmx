require 'skylab/porcelain/core'
require 'skylab/pub-sub/emitter'

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
    extend Skylab::Autoloader
    extend Skylab::PubSub::Emitter
    extend Skylab::Porcelain::Attribute::Definer
    extend Skylab::Porcelain::En::ApiActionInflectionHack
    extend Skylab::Porcelain::Bleeding::DelegatesTo

    inflection.stems.noun = 'treemap'

    attribute_meta_class MyAttributeMeta

    meta_attribute :default

    meta_attribute :enum do |name, ma|
      alias_method("#{name}_before_enum=", "#{name}=")
      define_method("#{name}=") do |val|
        if ma[:enum].include?(val)
          send("#{name}_before_enum=", val)
        else
          add_validation_error(name, val,
            "must be #{oxford_comma(ma[:enum].map{|x| pre x}, ' or ')} (had {{value}})")
          val
        end
      end
    end

    meta_attribute :path do |name, _|
      require 'skylab/face/path-tools'
      alias_method("#{name}_after_path=", "#{name}=")
      define_method("#{name}=") do |path|
        send("#{name}_after_path=", path ? ::Skylab::Face::MyPathname.new(path.to_s) : path)
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
      message.gsub!('{{value}}') { bad_value value }
      (validation_errors[name] ||= []).push(message)
    end

    attr_accessor :api_client

    def attributes
      singleton_class.attributes
    end

    def clear!
      attributes.keys.each { |k| instance_variable_set("@#{k}", nil) }
      (@validation_errors ||= {}).clear
      self
    end

    def error *a
      emit(:error, *a)
      false
    end

    def info *a
      emit(:info, *a)
      true
    end

    attr_accessor :stylus
    delegates_to :stylus, :and, :bad_value, :or, :oxford_comma, :pre, :param, :s

    def update_parameters! params
      param_keys, attrib_keys = [params, attributes].map(&:keys)
      good, bad = [:&, :-].map { |x| param_keys.send(x, attrib_keys) }
      if 0 < bad.length
        (validation_errors[nil] ||= []).push "unrecognized parameter#{s bad}: #{oxford_comma bad.map{|k| param k}}"
      end
      good.each { |k| send("#{k}=", params[k]) } # do the rest anyway, hell why not (aggregate validation errors)
      self
    end

    def validate
      attributes.with(:default).each do |k, v|
        if send(k).nil?
          send("#{k}=", v)
        end
      end
      validation_errors.each do |k, errs|
        if k
          error(%{#{param k} #{errs.join(' and it ')}})
        else
          errs.each { |e| error e }
        end
      end.size > 0 and return false # avoid superflous messages below
      ok = true
      if (a = attributes.select{ |n, m| m[:required] and ! send(n) }).any?
        ok = error("missing required parameter#{s a}: " <<
          "#{oxford_comma(a.map { |o| param o.first }) }")
      end
      ok
    end

    attr_reader :validation_errors

    def wire!
      yield self
    end
  end
end

