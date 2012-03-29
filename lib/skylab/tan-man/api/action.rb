module Skylab::TanMan
  class Api::Action
    extend Bleeding::DelegatesTo
    extend PubSub::Emitter
    extend Porcelain::AttributeDefiner

    # include MyActionInstanceMethods
    include Api::RuntimeExtensions
    include AttributeReflection::InstanceMethods
    include Api::AdaptiveStyle

    meta_attribute(*MetaAttributes[:boolean, :default, :mutex_boolean_set,:pathname, :required, :regex])

    emits Bleeding::EVENT_GRAPH.merge(MY_EVENT_GRAPH)
    event_class Api::Event

    delegates_to :class, :action_name

    def config
      @config ||= begin
        require_relative '../models/config'
        Models::Config::Controller.new(self)
      end
    end

    def error msg
      # add_invalid_reason msg @todo
      emit :error, msg
      false
    end

    def error_emitter ; self end # meta attributes compat

    def initialize runtime
      @runtime = runtime
      on_error { |e| add_invalid_reason e }
      on_all { |e| self.runtime.emit(e) }
    end

    def invalid_reasons?
      invalid_reasons_count.nonzero?
    end

    def invalid_reasons_count
      (@invalid_reasons ||= nil) ? @invalid_reasons.count : 0
    end

    def invoke
      execute # the specific action is expected to implement this
    end

    attr_reader :runtime

    delegates_to :root_runtime, :singletons

    delegates_to :runtime, :stdout

    delegates_to :runtime, :text_styler

    def skip msg
      emit :skip, msg
      nil
    end

    def update_attributes! h
      c0 = invalid_reasons_count
      h.each { |k, v| send("#{k}=", v) }
      c0 >= invalid_reasons_count
    end

    def valid?
      invalid_reasons? and return false
      required_ok? # more hooking required
      ! invalid_reasons?
    end
  end

  class << Api::Action

    def action_name
      to_s.match(/[^:]+$/)[0].gsub(/([a-z])([A-Z])/) { "#{$1}-#{$2}" }.downcase
    end

    def call runtime, request
      o = new(runtime)
      runtime.set_transaction_attributes(o, request) or return false
      o.set_defaults_if_nil!
      o.valid? or return false
      o.invoke
    end
  end
end

