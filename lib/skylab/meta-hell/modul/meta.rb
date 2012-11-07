module Skylab::MetaHell
  class Modul::Meta
    attr_accessor :name, :children, :blocks

    def _build *_
      ::Module.new
    end

    def _lock!   ; @locked and fail('sanity') ; @locked = true end
    def _locked? ; @locked end
    def _unlock! ; @locked or fail('sanity') ; @locked = false end

    def initialize n, cx=[], bx=[]
      @locked = false
      @name, @children, @blocks = [n, cx, bx]
    end
  end
end
