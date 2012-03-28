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
          error("#{name} cannot be #{value.inspect}.  It must be "<<
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
          error(meta[:on_regex_fail] || "#{str.inspect} did not match pattern for #{name}: /#{re.source}/")
          str
        end
      end
    end
  end

  # @todo this requires a 'pre' formatter
  module MetaAttributes::Required extend Porcelain::AttributeDefiner
    meta_attribute :required
  end
  module MetaAttributes::Required::InstanceMethods
    def required_ok?
      if (a = attribute_definer.attributes.map.select { |k, h| h[:required] && send(k).nil? }).size.nonzero?
        error( "missing required attribute#{'s' if a.size != 1}: " <<
          "#{oxford_comma(a.map { |o| "#{pre o.first}" }, ' and ')}")
      else
        true
      end
    end
  end

  module AttributeReflection
    # once this settles down it will get pushed up @todo
  end
  module AttributeReflection::InstanceMethods
    def attributes
      AttributeReflection::InstanceAttributeIterator.new(self)
    end
    def attribute_definer # @todo there is a hack you have to do if you are doing metaclass hacking
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
    alias_method :attribute_definer, :singleton_class # @todo
    attribute :global_conf_path, proc: true, default: ->{ "#{ENV['HOME']}/.tanman-config" }
    attribute :local_conf_config_name, default: 'config'
    attribute :local_conf_dirname, default: '.tanman'
    attribute :local_conf_maxdepth, default: nil # @todo, with all of these etc
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
    include GlobalStyle
    def pre str
      runtime.text_styler.pre str # ick not sure
    end
  end

  module Api::UniversalStyle
    def pre str
      "\"#{str}\""
    end
  end

  module MyActionInstanceMethods
    # (note: the question of what should be in a cli action and what
    #  should be in an api action and what should be a model controller
    #  action is an area of active exploration.)
    #

    extend Bleeding::DelegatesTo
    include AttributeReflection::InstanceMethods
    include GlobalStyle

    def add_invalid_reason str
      (@invalid_reasons ||= []).push str
    end

    def config
      @config ||= begin
        require_relative 'models/config'
        Models::Config::Controller.new(self)
      end
    end

    def error msg
      add_invalid_reason msg
      emit :error, msg
      false
    end
    def skip msg
      emit :skip, msg
      nil
    end

    def format_error event
      event.tap do |e|
        if runtime.runtime
          subj, verb, obj = [runtime.runtime.program_name, action.name, runtime.actions_module.name]
        else
          subj, verb = [runtime.program_name, action.name]
        end
        e.message = "#{subj} failed to #{verb}#{" #{obj}" if obj}: #{e.message}"
      end
    end

    # experimental, might get pushed up to porcelain @todo
    def full_action_name_parts
      a = [action.name]
      root_id = root_runtime.object_id
      current = self
      until root_id == current.runtime.object_id
        current = current.runtime
        a.push current.name
      end
      a.reverse
    end

    def invalid_reasons?
      @invalid_reasons && @invalid_reasons.size.nonzero?
    end

    def invalid_reasons_count
      @invalid_reasons ? @invalid_reasons.count : 0
    end

    def my_action_init
      @config = nil
      @invalid_reasons ||= nil
    end

    def root_runtime
      runtime ? ( runtime.respond_to?(:root_runtime) ? runtime.root_runtime : runtime ) : self
    end

    attr_reader :runtime

    def valid?
      invalid_reasons? and return false
      required_ok? # more hooking required
      ! invalid_reasons?
    end

    delegates_to :root_runtime, :singletons

    delegates_to :runtime, :stdout
  end

  class Api::Singletons
    def clear_cache!
      @config.clear_cache! if @config
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

    def is? sym
      sym == tag.name or tag.ancestors.include?(sym)
    end
    def json_data
      if Array === payload
        [tag.name, *payload]
      elsif Hash === payload
        [tag.name, payload]
      else
        [tag.name]
      end
    end
    def to_json *a
      json_data.to_json(*a)
    end
  end
end

