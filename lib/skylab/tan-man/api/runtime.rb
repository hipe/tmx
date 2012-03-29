require_relative 'binding'
require 'json'

module Skylab::TanMan
  class Api::RootRuntime
    include Api::UniversalStyle

    def clear_cache!
      @singletons.clear_cache!
    end
    def initialize
      @singletons = Api::Singletons.new
    end
    def invoke *a
      events = Api::ActionEvents.new(self)
      events.debug! if Hash === a.last && a.last.delete(:_debug)
      result = events.invoke(*a)
      if result.respond_to?(:each) # @todo{after:.3}: needs something maybe
        result.each do |item|
          events.emit(:row) do
            { row_data: item.to_a }
          end
        end
      end
      events
    end
    attr_reader :singletons
    def text_styler
      self
    end
  end

  class Api::ActionEvents < Array
    extend Bleeding::DelegatesTo
    extend PubSub::Emitter
    include Api::InvocationMethods

    emits EVENT_GRAPH.merge( row: :out )
    event_class Api::Event

    attr_accessor :debug
    alias_method :debug?, :debug
    def debug!
      tap { |me| me.debug = true }
    end
    def first_error
      detect { |e| e.is?(:error) }
    end
    def initialize runtime
      self.debug = false
      self.runtime = runtime
      super()
      on_all do |e|
        debug? and $stdout.puts("  >>> api event: #{e.type}: #{e}")
        push e
      end
    end
    def invalid msg
      emit(:error, msg)
      false
    end
    def json_data
      map(&:json_data)
    end
    attr_accessor :runtime
    alias_method :root_runtime, :runtime
    def set_transaction_attributes transaction, attributes
      attributes or return true
      if (bad = attributes.keys - transaction.class.attributes.keys).any?
        emit(:error, "invalid action parameters(s): (#{bad.join(', ')})")
        return false
      end
      transaction.update_attributes!(attributes)
    end
    delegates_to :runtime, :singletons

    # "Multipart Events"
    # This is just a q & d p. o. c !!! many holes below, memory leaks etc
    def stdout
      @stdout ||= begin
        o = Api::Whatever.new
        buffer = StringIO.new
        list = self
        o[:write] = ->(str) { buffer.write(str) }
        o[:puts] = ->(str) do
          buffer.puts(str)
          payload = buffer.string.dup # ! you've gotta dup it
          buffer.truncate(0)
          list.emit(:out, payload)
        end
        o
      end
    end
    delegates_to :runtime, :text_styler
    def success?
      ! first_error
    end
    def to_json *a
      json_data.to_json(*a) # here only as a sanity check
    end
  end
  class Api::Whatever
    class << self
      public :define_method
    end
    def []= (a, b)
      singleton_class.define_method(a, &b)
    end
  end
end

