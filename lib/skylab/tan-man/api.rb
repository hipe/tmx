module Skylab::TanMan

  ROOT = ::Skylab::Face::MyPathname.new(File.expand_path('..', __FILE__))

  module API end

  class API::RuntimeError < ::RuntimeError ; end # just for fun

  class << API
    extend Porcelain::AttributeDefiner
    meta_attribute(*MetaAttributes[:default, :proc])
    include Core::Attribute::Reflection::InstanceMethods
    alias_method :attribute_definer, :singleton_class # @experimental:
    # this means that the objects will no longer use their class as the attribute_definer
    attribute :global_conf_path, proc: true, default: ->{ "#{ENV['HOME']}/.tanman-config" }
    attribute :local_conf_config_name, default: 'config'
    attribute :local_conf_dirname, default: '.tanman'
    attribute :local_conf_maxdepth, default: nil # meaningful (and didactic) nil
    attribute :local_conf_startpath, proc: true, default: ->{ ::Skylab::Face::MyPathname.pwd }
  end
  API.set_defaults_if_nil!

  module GlobalStyle
    include Porcelain::En::Methods # oxford_comma, s()
    # @later this might be stylus pattern
  end

  module API::AdaptiveStyle
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

  module API::UniversalStyle
    def pre str
      "\"#{str}\""
    end
  end

  module API::RuntimeExtensions
    extend Bleeding::DelegatesTo
    include GlobalStyle
    def add_invalid_reason mixed
      (@invalid_reasons ||= []).push mixed
    end
    def root_runtime
      if parent
        parent.root_runtime
      else
        self
      end
    end
    delegates_to :runtime, :stdout, :text_styler
  end

  class API::Singletons
    def clear
      @config.clear if @config
    end
    def config
      @config ||= begin
        TanMan::Models::Config::Singleton.new
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
      @api = API::Runtime::Root.new
    end
  end

  class API::Event < ::Skylab::PubSub::Event
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

  API::Emitter = Object.new
  class << API::Emitter
    def new *a
      ::Skylab::PubSub::Emitter.new(*a).tap do |graph|
        graph.event_class API::Event
      end
    end
  end

  # --*--

  module API::InvocationMethods
    include ::Skylab::Autoloader::Inflection::Methods # constantize
    def invoke action=nil, args=nil, &block
      if ::Hash === action && ! args
        args = action
        action = nil
      end
      action ||= runtime.on_no_action_name
      action = [action] unless ::Array === action

      prev = 'actions'
      klass = action.reduce(API::Actions) do |mod, name|
        /\A[-a-z]+\z/ =~ name or return invalid("invalid action name: #{name}")
        const = constantize name
        if ! mod.const_defined? const, false
          if mod.const_probably_loadable? const
            # will get loaded below at const_get
          else
            return invalid(%<"#{prev}" has no "#{name}" action>)
          end
        end
        prev = name
        mod.const_get const, false
      end
      klass.call self, args, &block
    end
    def set_transaction_attributes transaction, attributes
      attributes or return true
      transaction.update_attributes! attributes
    end
  end
end
