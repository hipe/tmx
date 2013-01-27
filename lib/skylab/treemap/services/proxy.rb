module Skylab::Treemap
  class Model::Proxy < ::BasicObject
    # makes a generic proxy class that makes generic proxy objects
    # that proxy calls ..

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
        $stderr.send :raise, "no upstream set yet! can't #{
          }do anything - (#{ m })"
      end
    end

    def upstream= upstream
      @upstream = upstream
    end

  protected

    def initialize upstream=nil
      @upstream = upstream # nil ok
      nil
    end
  end
end
