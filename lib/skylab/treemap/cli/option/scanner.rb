module Skylab::Treemap

  class CLI::Option::Scanner # for ::OptionParser hacks

    attr_reader :count

    def fetch query, otherwise=nil
      block_given? and fail 'no'
      while x = self.next
        break( found = x ) if query[ x ]
      end
      if found
        found
      else
        otherwise ||= -> { raise ::KeyError, 'item matching query not found.' }
        otherwise[]
      end
    end

    attr_reader :is_hot

    attr_reader :last

    def next
      if @is_hot
        r = @enum.next
        @count += 1
        @last = filter r
      end
    rescue ::StopIteration
      @is_hot = nil
    end

  protected

    def initialize enum
      @is_hot = true
      @count = 0
      @last = nil
      @enum = ::Enumerator.new do |y|
        enum.each { |x| y << x }
      end
      @fly = CLI::Option.new(
        * 6.times.map { nil } ) # for now
    end

    unparse = -> sw do
      args = [ ] # this might alter the order of things, it is a hack
      x = sw.short.first and args << x
      x = sw.long.first and args << "#{ sw.long.first }#{ sw.arg }"
      args
    end

    define_method :filter do |sw|
      @fly.set_from_args unparse[ sw ]
      @fly
    end
  end
end
