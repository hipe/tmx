require 'json'

module Skylab::TanMan
  module API::Runtime end
  class API::Runtime::Root
    include API::UniversalStyle

    def clear
      @singletons.clear
    end
    def initialize
      @singletons = API::Singletons.new
    end
    def invoke *a, &b
      events = API::ActionEvents.new(self)
      events.debug! if Hash === a.last && a.last.delete(:_debug)
      result = events.invoke(*a, &b)
      if result.respond_to?(:each) # @todo{after:.3}: needs something maybe
        result.each do |item|
          events.emit(:row, row_data: item.to_a)
        end
      end
      events
    end
    attr_reader :singletons
    def text_styler
      self
    end
  end

  class API::ActionEvents < Array
    extend Bleeding::DelegatesTo
    extend ::Skylab::PubSub::Emitter
    include API::InvocationMethods

    emits EVENT_GRAPH.merge( row: :out )
    event_class API::Event

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
        o = API::Whatever.new
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
    alias_method :infostream, :stdout # somebody tell me what the hell is going
    delegates_to :runtime, :text_styler
    def success?
      ! first_error
    end
    def to_json *a
      json_data.to_json(*a) # here only as a sanity check
    end
  end
  class API::Whatever
    class << self
      public :define_method
    end
    def []= (a, b)
      singleton_class.define_method(a, &b)
    end
  end
end

