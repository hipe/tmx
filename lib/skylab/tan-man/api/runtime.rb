require_relative 'binding'
require 'json'

module Skylab::TanMan
  # class Api::Runtime < Api::Binding
  class Api::RootRuntime
    def invoke *a
      events = Api::ActionEvents.new
      events.invoke(*a)
      events
    end
  end

  class Api::ActionEvents < Array
    extend PubSub::Emitter
    include Api::InvocationMethods
    emits EVENT_GRAPH
    event_class Api::Event

    def first_error
      detect { |e| :error == e.type } # might become more graphical
    end
    def initialize
      super()
      on_all do |e|
        # $stdout.puts "#{self.class}#push #{e}"
        push e
      end
    end
    def invalid msg
      emit(:error, msg)
      self
    end
    def json_data
      map(&:json_data)
    end
    def set_transaction_attributes transaction, attributes
      if (bad = attributes.keys - transaction.class.attributes.keys).any?
        emit(:error, "invalid action parameters(s): (#{bad.join(', ')})")
        return false
      end
      transaction.update_attributes!(attributes)
    end
    def success?
      ! first_error
    end
    def to_json *a
      json_data.to_json(*a) # here only as a sanity check
    end
  end
end

