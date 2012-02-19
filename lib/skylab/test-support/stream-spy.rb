module Skylab::TestSupport
  class StreamSpy
    def self.standard
      require 'stringio'
      new.tap do |spy|
        spy.tty!
        spy[:buffer] = StringIO.new
      end
    end
    [:puts, :write].each do |m|
      define_method(m) do |*a, &b|
        listeners.each { |l| l.send(m, *a, &b) }
      end
    end
    def [] key
      @listeners[@key_index[key]]
    end
    def []= key, value
      index = @key_index.include?(key) ?
        @key_index[key] : (@key_index[key] = @listeners.length)
      @listeners[index] = value
    end
    def debug!
      self[:debug] = $stderr # yeah ..
      self
    end
    def initialize
      @key_index = {}
      @listeners = []
    end
    attr_reader :listeners
    def string
      self[:buffer].string
    end
    def tty!
      @tty = true
      self
    end
    def no_tty!
      @tty = false
      self
    end
    attr_reader :tty
    alias_method :tty?, :tty
  end
end

