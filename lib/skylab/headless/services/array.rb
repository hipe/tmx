module Skylab::Headless

  module Headless::Services::Array
    # [#070] - #todo merge this into that
  end

  class Headless::Services::Array::Scanner

    # assumes immutable array

    def gets
      if @pos < @length
        res = @arr[@pos]
        @pos += 1
        res
      end
    end

    def eos?  # "end of scan"
      @pos >= @length
    end

    attr_reader :arr, :pos, :length

  protected

    def initialize arr
      @arr = arr
      @pos = 0
      @length = @arr.length
    end
  end
end
