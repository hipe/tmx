module Skylab::TanMan
  class API::Action
    extend Bleeding::DelegatesTo
    extend ::Skylab::PubSub::Emitter
    extend Porcelain::Attribute::Definer

    include Core::Action::InstanceMethods
    include Core::Attribute::Reflection::InstanceMethods
    include Core::Pen::Methods::Adaptive

    meta_attribute(*Core::MetaAttributes[:boolean, :default, :mutex_boolean_set,:pathname, :required, :regex])

    event_class API::Event

    delegates_to :class, :action_name

    def config
      @config ||= begin
        TanMan::Models::Config::Controller.new(self)
      end
    end

    def error msg
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
    alias_method :parent, :runtime # @todo 100

    delegates_to :root_runtime, :singletons

    def infostream ; runtime.infostream end
    alias_method :stderr, :infostream # #jawbreak

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

  class << API::Action

    def action_name # re-evaluated at [#033]
      to_s.match(/[^:]+$/)[0].gsub(/([a-z])([A-Z])/) { "#{$1}-#{$2}" }.downcase
    end

    def call runtime, request
      o = new(runtime)
      yield(o) if block_given?
      runtime.set_transaction_attributes(o, request) or return false
      o.set_defaults_if_nil!
      o.valid? or return false
      o.invoke
    end
  end
end
