module Skylab::Headless
  module SubClient end
  module SubClient::InstanceMethods
    def emit(*a) ; io_adapter.emit(*a) end
    def error(s) ; emit(:error, s) ; false end
    def initialize(r) ; self.request_runtime = r end
    def io_adapter ; request_runtime.io_adapter end
    def params ; request_runtime.params end
    def pen ; io_adapter.pen end
    attr_accessor :request_runtime
    # --- * ---
    def em s ; pen.em s end
    # --- * ---
    THE_ENGLISH_LANGUAGE = # @id: 6
      { a: ['a '], an: ['an '], is: ['is', 'are'], s:[nil, 's'] }
    def and_ a, last = ' and ', sep = ', '
      @_coun = ::Fixnum === a ? a : a.length
      (hsh = Hash.new(sep))[a.length - 1] = last
      [a.first, * (1..(a.length-1)).map { |i| [ hsh[i], a[i] ] }.flatten].join
    end
    def s count=nil, part=nil
      args = [count, part].compact
      part = ::Symbol === args.last ? args.pop : :s
      coun = 1 == args.length ? args.pop : @_coun
      @_coun = ::Fixnum === coun ? coun : coun.length # gigo
      THE_ENGLISH_LANGUAGE[part][1 == @_coun ? 0 : 1]
    end
  end
end
