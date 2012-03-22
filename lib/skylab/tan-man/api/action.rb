module Skylab::TanMan
  class Api::Action
    extend Bleeding::DelegatesTo
    extend PubSub::Emitter
    extend Porcelain::AttributeDefiner

    include MyActionInstanceMethods

    meta_attribute(*MetaAttributes[:boolean, :default, :pathname, :required, :regex])

    emits Bleeding::EVENT_GRAPH.merge(MY_EVENT_GRAPH)
    event_class Api::Event

    delegates_to :class, :action_name

    def initialize runtime
      my_action_init
      @runtime = runtime
      on_error { |e| add_invalid_reason e }
      on_all { |e| self.runtime.emit(e) }
    end

    def invoke
      execute # the specific action is expected to implement this
    end

    attr_reader :runtime

    def update_attributes! h
      c0 = invalid_reasons_count
      h.each { |k, v| send("#{k}=", v) }
      c0 >= invalid_reasons_count
    end
  end

  class << Api::Action

    def action_name
      to_s.match(/[^:]+$/)[0].gsub(/([a-z])([A-Z])/) { "#{$1}-#{$2}" }.downcase
    end

    def call runtime, request
      new(runtime).tap do |transaction|
        runtime.set_transaction_attributes(transaction, request) or return false
        transaction.set_defaults_if_nil!
        transaction.valid? or return false
        return transaction.invoke
      end
    end
  end
end

