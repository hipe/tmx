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
  VERBS = { is: ['exist', 'is', 'are'], no: ['no '] }

  LOCAL_CONF_DIRNAME = '.tanman'
  LOCAL_CONF_CONFIG_NAME = 'config'


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
      self.class.attributes.select { |k, v| v.key?(:default) and send(k).nil? }.each do |k, v|
        send("#{k}=", v[:default].respond_to?(:call) ? v[:default].call : v[:default])
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

  module MetaAttributes::Required extend Porcelain::AttributeDefiner
    meta_attribute :required
  end
  module MetaAttributes::Required::InstanceMethods
    include Bleeding::Styles
    def required_ok?
      if (a = self.class.attributes.map.select { |k, h| h[:required] && send(k).nil? }).size.nonzero?
        error( "missing required attribute#{'s' if a.size != 1}: " <<
          "#{oxford_comma(a.map { |o| "#{pre o.first}" }, ' and ')}")
      else
        true
      end
    end
  end

  class << Api
    extend Porcelain::AttributeDefiner
    meta_attribute(*MetaAttributes[:proc])
    attribute :global_conf_path, :proc => true
  end
  Api.global_conf_path { "#{ENV['HOME']}/.tanrc" }


  module MyActionInstanceMethods
    # (note: the question of what should be in a cli action and what
    #  should be in an api action is an area of active exploration.)
    #


    extend Bleeding::DelegatesTo

    def add_invalid_reason str
      (@invalid_reasons ||= []).push str
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
      @invalid_reasons ||= nil
    end

    def s a, v=nil # just one tiny hard to read hack
      v.nil? and return( 1 == a.size ? '' : 's' )
      VERBS[v][case a.count ; when 0 ; 0 ; when 1 ; 1 ; else 2 ; end]
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
    def config
      @config and return @config
      require ROOT.join('models/config')
      @confg = Models::Config::Singleton.new
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

  class Api::Event < PubSub::Event
    # this is all very experimental and subject to change!
    def json_data
      if Array === payload
        [tag.name, *payload]
      elsif Hash === payload
        [tag.name, [payload]]
      else
        [tag.name]
      end
    end
    def to_json *a
      json_data.to_json(*a)
    end
  end
end

