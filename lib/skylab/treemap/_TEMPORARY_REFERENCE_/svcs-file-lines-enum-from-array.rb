module Skylab::Treemap

  class Services::File::Lines::Enumerator::From::Array < ::Enumerator

    def initialize arr
      block_given? and fail('no')
      index = -1
      @last_number = -> { index + 1 }
      @gets = -> do
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

    M_etaHell.function self, :last_number, :gets
  end
end
