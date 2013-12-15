module Skylab::MetaHell

  module Proxy::Filter
  end

  class Proxy::Filter::Post < ::BasicObject

    # post-filter.
    # makes a generic proxy class that makes a generic proxy objects that
    # is constructed with one upstream. Although it is the proxy wall that
    # receives the message before the upstream does, here is why it is called
    # an upstream and not a downstream: for a certain subset of methods,
    # whatever that upstream passes back as a result, the proxy object runs
    # it through a function of the user's creation.
    #
    # that pairing of method names with functions is accomplished by a hash
    # that is passed during production of the proxy _class_.
    #
    # Amusingly we don't know why we originally wrote this anymore (it
    # came from super legacy tan-man and stayed on top of refactorings b/c
    # it was well tested.) but not matter, it is here if we ever need it.

    class << self
      alias_method :treemap_original_new, :new
    end

    root_class = self

    define_singleton_method :new do |hash|
      kls = ::Class.new root_class
      kls.class_eval do
        class << self
          undef_method :new
          alias_method :new, :treemap_original_new
        end
        hash.each do |meth, func|
          define_method meth do |*a, &b|
            x = @upstream.send meth, *a, &b
            func[ x ]
          end
        end
      end
      kls
    end

    # --*--

    def method_missing m, *a, &b
      if @upstream
        @upstream.send m, *a, &b
      else
        nil.send :raise, "no upstream set yet! can't #{
          }do anything - (#{ m })"
      end
    end

    def upstream= upstream
      @upstream = upstream
    end

  private

    def initialize upstream=nil
      @upstream = upstream # nil ok
      nil
    end
  end
end
