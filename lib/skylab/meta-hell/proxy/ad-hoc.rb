module Skylab::MetaHell

  class Proxy::Ad_Hoc < ::BasicObject

    # #experimental - for quick and dirty hacks or experimentation,
    # simply takes a hash-like whose keys are presumed to represent method
    # names and whose values are presumed to be functions, and make and
    # object out of it.
    #
    # (Alternate names for this that have been or are being considered
    # or have been used for this are / were: `Generic`, `Plastic`, `Dynamic`.
    # kind of amusing, actually)
    #
    # (This was the orignal home of [#mh-009] - it was developed right before
    # we found out about define_singleton_method, but it stays b/c it's actually
    # a bit clearer to read than hacks like *that*. If for no other reason
    # it might be only slighly more useful than using ::Object because it leads
    # you here to read this.) (hm..)
    #

    class << self
      alias_method :[], :new
    end

  protected

    def initialize h
      singleton_class = class << self
        self
      end
      singleton_class.class_exec do
        if ! h.key? :inspect
          define_method :inspect do
            "<##{ Proxy::Ad_Hoc }:(#{ h.keys.join ', ' })>"
          end
        end
        h.each do |k, func|
          define_method k do |*a, &b|          # necessary to do in these two
            func[ *a, &b ]                     # steps because we want to call
          end                                  # the proc in its original ctxt
        end
      end
    end
  end
end
