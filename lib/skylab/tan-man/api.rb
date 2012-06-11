require File.expand_path('../..', __FILE__)
require 'skylab/face/path-tools'
require 'skylab/porcelain/attribute-definer'
require 'skylab/porcelain/bleeding'
require 'skylab/pub-sub/emitter'

module Skylab::TanMan
  Face = Skylab::Face
  Bleeding = Skylab::Porcelain::Bleeding
  Porcelain = Skylab::Porcelain
  PubSub = Skylab::PubSub
  TanMan = Skylab::TanMan

  MY_EVENT_GRAPH = { :info => :all, :out => :all, :no_config_dir => :error, :skip => :info }
  EVENT_GRAPH = Bleeding::EVENT_GRAPH.merge(MY_EVENT_GRAPH)

  ROOT = Face::MyPathname.new(File.expand_path('..', __FILE__))

  module Api
  end

  module MetaAttributes
  end

  module Models
  end

  class << MetaAttributes
    def all
      constants.map { |k| const_get(k) }
    end
    def [](*a)
      a.map do |k|
        konst = k.to_s.gsub(/(?:^|([a-z])_)([a-z])/) { "#{$1}#{$2.upcase}" }.intern
        const_get konst
      end
    end
  end

  module MetaAttributes::Boolean extend Porcelain::AttributeDefiner
    meta_attribute :boolean do |name, meta|
      alias_method "#{name}?", name
    end
  end

  module MetaAttributes::Default extend Porcelain::AttributeDefiner
    meta_attribute :default
  end
  module MetaAttributes::Default::InstanceMethods
    def set_defaults_if_nil!
      attribute_definer.attributes.select { |k, v| v.key?(:default) and send(k).nil? }.each do |k, h|
        (val = h[:default]).respond_to?(:call) and ! h[:proc] and val = val.call
        send("#{k}=", val)
      end
    end
  end

  module MetaAttributes::MutexBooleanSet extend Porcelain::AttributeDefiner
    meta_attribute :mutex_boolean_set do |name, h|
      set = h[:mutex_boolean_set]
      alias_method(after = "#{name}_after_mutex_boolean_set=", "#{name}=")
      define_method("#{name}=") do |value|
        intern = String === value ? value.intern : value # always normalize strings for now, you cannot use them
        if set.include?(intern)
          send(after, intern)
        else
          error_emitter.error("#{name} cannot be #{value.inspect}.  It must be "<<
            "#{Porcelain::En.oxford_comma(set.map { |o| o.to_s.inspect })}")
          value
        end
      end
      set.each do |intern|
        define_method("#{intern}?") { intern == send(name) }
      end
    end
  end

  module MetaAttributes::Pathname extend Porcelain::AttributeDefiner
    meta_attribute :pathname do |name, _|
      alias_method(after = "#{name}_after_pathname=", "#{name}=")
      define_method("#{name}=") do |path|
        send(after, path ? Face::MyPathname.new(path.to_s) : path)
        path
      end
    end
  end

  module MetaAttributes::Proc extend Porcelain::AttributeDefiner
    meta_attribute :proc do |name, _|
      alias_method(get_proc = "#{name}_proc", name)
      define_method(name) do |&block|
        if block
          self.send("#{name}=", block)
        else
          send(get_proc)
        end
      end
    end
  end

  module MetaAttributes::Regex extend Porcelain::AttributeDefiner
    meta_attribute :on_regex_fail
    meta_attribute :regex do |name, meta|
      alias_method(after = "#{name}_after_regex=", "#{name}=")
      define_method("#{name}=") do |str|
        if (re = meta[:regex]) =~ str
          send(after, str)
        else
          error_emitter.error(meta[:on_regex_fail] || "#{str.inspect} did not match pattern for #{name}: /#{re.source}/")
          str
        end
      end
    end
  end

  # @note: this requires that the object define an attribute_definer that responds to attributes()
  # and it requires an error_emitter and it requires the styler methods: oxford_comma, pre.
  # A required attribute is considered as not provided IFF it returns nil.
  #
  module MetaAttributes::Required extend Porcelain::AttributeDefiner
    meta_attribute :required
  end
  module MetaAttributes::Required::InstanceMethods
    def required_ok?
      if (a = attribute_definer.attributes.map.select { |k, h| h[:required] && send(k).nil? }).size.nonzero?
        error_emitter.error( "missing required attribute#{'s' if a.size != 1}: " <<
          "#{oxford_comma(a.map { |o| "#{pre o.first}" }, ' and ')}")
      else
        true
      end
    end
  end

  module AttributeReflection
    # once this settles down it will get pushed up @todo{after:.3}
  end
  module AttributeReflection::InstanceMethods
    def attributes
      AttributeReflection::InstanceAttributeIterator.new(self)
    end

    # @note: the default attribute definer for a typical object is its ordinary class.
    # In some cases -- e.g. if you are dealing with a class or module object and want
    # to use attribute definer for *that* -- you will want to redefine this method
    # to return the singleton class instead, for reflection to work (which is required
    # for some kind of meta-attribute setters, etc)
    #
    def attribute_definer
      self.class
    end
  end
  class AttributeReflection::InstanceAttributeIterator < ::Enumerator
    def initialize obj
      super() do |y|
        attrs = obj.class.attributes
        attrs.each do |k, h|
          y << [k, obj.send(k)] # VERY experimental interface
        end
      end
    end
    def to_h
      Hash[to_a]
    end
  end

  class << Api
    extend Porcelain::AttributeDefiner
    meta_attribute(*MetaAttributes[:default, :proc])
    include AttributeReflection::InstanceMethods
    alias_method :attribute_definer, :singleton_class # @experimental:
    # this means that the objects will no longer use their class as the attribute_definer
    attribute :global_conf_path, proc: true, default: ->{ "#{ENV['HOME']}/.tanman-config" }
    attribute :local_conf_config_name, default: 'config'
    attribute :local_conf_dirname, default: '.tanman'
    attribute :local_conf_maxdepth, default: nil # meaningful (and didactic) nil
    attribute :local_conf_startpath, proc: true, default: ->{ Face::MyPathname.pwd }
  end
  Api.set_defaults_if_nil!

  VERBS = { is:   ['exist', 'is', 'are'],
            no:   ['no ', 'the only '],
            this: ['these', 'this', 'these'] }
  module GlobalStyle
    def oxford_comma *a
      Porcelain::En.oxford_comma(*a)
    end
    def s a, v=nil # just one tiny hard to read hack
      count = Numeric === a ? a : a.count
      v.nil? and return( 1 == count ? '' : 's' )
      VERBS[v][case count ; when 0 ; 0 ; when 1 ; 1 ; else 2 ; end]
    end
  end

  module Api::AdaptiveStyle
    # Simply provides convenience methods that are shorthand wrappers
    # for the below style methods, for whose implementation text_styler()
    # is relied up.
    #
    # Because the including module relies upon the text_styler() for
    # the implementations and the text_styler() may be a variety of
    # different implementations based on the root runtime, for e.g.
    # this is considered to be the implementation for "adaptive style."
    #
    extend Bleeding::DelegatesTo
    include GlobalStyle

    delegates_to :text_styler, :pre
  end

  module Api::UniversalStyle
    def pre str
      "\"#{str}\""
    end
  end

  module Api::RuntimeExtensions
    extend Bleeding::DelegatesTo
    include GlobalStyle
    def add_invalid_reason mixed
      (@invalid_reasons ||= []).push mixed
    end
    def root_runtime
      if runtime
        runtime.root_runtime
      else
        self
      end
    end
    delegates_to :runtime, :stdout, :text_styler
  end

  class Api::Singletons
    def clear
      @config.clear if @config
    end
    def config
      @config ||= begin
        require_relative 'models/config'
        Models::Config::Singleton.new
      end
    end
    def initialize
      @config = nil
    end
  end

  @api = nil
  class << self
    def api
      @api and return @api
      require_relative 'api/runtime'
      @api = Api::RootRuntime.new
    end
  end

  module Api::Autoloader
    # @todo: after:#102
    # experimental: const_missing hax can suck, but we want to avoid the overhead of
    # loading things like code-molester's config file parser unless we need it
    def self.init mod
      here = %r{^(.+)\.rb:\d+:in `}.match(caller[0])[1]
      mod.singleton_class.send(:alias_method, :orig_const_missing, :const_missing)
      mod.singleton_class.send(:define_method, :const_missing) do |const|
        stem = const.to_s.gsub(/(?<=^|([a-z]))([A-Z])/) { "#{'-' if $1}#{$2.downcase}" }
        require "#{here}/#{stem}"
        const_get const
      end
    end
  end

  class Api::Event < PubSub::Event
    # this is all very experimental and subject to change!
    def json_data
      case payload
      when String, Hash ; [tag.name, payload]
      when Array        ; [tag.name, *payload]
      else              ; [tag.name] # no payload for you!
      end
    end
    def message= msg
      update_attributes!(message: msg)
    end
    def to_json *a
      json_data.to_json(*a)
    end
  end

  Api::Emitter = Object.new
  class << Api::Emitter
    def new *a
      PubSub::Emitter.new(*a).tap do |graph|
        graph.event_class Api::Event
      end
    end
  end
end

