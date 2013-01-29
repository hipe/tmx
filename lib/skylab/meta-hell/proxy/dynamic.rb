module Skylab::MetaHell

  class Proxy::Dynamic < ::BasicObject

    # #experimental - for quick and dirty hacks or experimentation,
    # simply takes a hash-like whose keys are presumed to represent method
    # names and whose values are presumed to be functions, and make and
    # object out of it.
    #
    # (Alternate names for this that have been or are being considered
    # or have been used for this are / were: `Generic`, `Plastic`)
    #
    # (This was the orignal home of [#mh-009] - it was developed right before
    # we found out about define_singleton_method, but it stays b/c it's actually
    # a bit clearer to read than hacks like *that*. If for no other reason
    # it might be only slighly more useful than using ::Object because it leads
    # you here to read this.) (hm..)
    #

    def self.[] h
      new h
    end

  protected

    def initialize h
      singleton_class = class << self
        self
      end
      singleton_class.class_exec do
        h.each do |k, func|
          define_method k, &func
        end
      end
    end
  end
end
