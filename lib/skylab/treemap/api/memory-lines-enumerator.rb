module Skylab::Treemap::API
  class MemoryLinesEnumerator < ::Enumerator
    def last_number
      @last_number.call
    end

    alias_method :orig_next, :next

    def gets
      @next.call
    end

    def initialize arr
      block_given? and fail('no')
      index = -1
      @last_number = ->() { index + 1 }
      @next = ->() do
        if (index + 1) < arr.length
          arr[index += 1]
        else
          nil
        end
      end
      super( ) do |y|
        while index + 1 < arr.length
          y << arr[index += 1]
        end
      end
    end
  end
end
