module Skylab::MetaHell
  class Modul::Meta < ::Struct.new :name, :children, :blocks
    def initialize n, cx=[], bx=[]
      @locked = false
      super n, cx, bx
    end
    def _lock!   ; @locked and fail('sanity') ; @locked = true end
    def _locked? ; @locked end
    def _unlock! ; @locked or fail('sanity') ; @locked = false end
  end
end
