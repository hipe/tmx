module Skylab::MetaHell
  class Modul::Meta
    attr_accessor :name, :create_mod_f, :children, :blocks

    def _lock!   ; @locked and fail('sanity') ; @locked = true end
    def _locked? ; @locked end
    def _unlock! ; @locked or fail('sanity') ; @locked = false end

    def const
       @name.to_s.split(Modul::Creator::SEP).last.intern
    end

    def initialize name, create_mod_f
      @locked = false
      @name, @create_mod_f, @children, @blocks = [name, create_mod_f, [], []]
    end
  end
end
