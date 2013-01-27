module Skylab::Treemap
  module MetaHell
    include ::Skylab::MetaHell    # we won't have its autolaoder, so..
    ::Skylab::MetaHell::Autoloader  || nil
    ::Skylab::MetaHell::DelegatesTo || nil
    ::Skylab::MetaHell::Formal      || nil
  end                             # it's ugly, and tracked by [#003]

  module MetaHell::InstanceMethods

  protected
                                  # (this method is protected hence
                                  # the name need not be all terse &
    def redefine_method! name, func  # pretty-like.)
      if respond_to? name
        singleton_class.send :alias_method, "orig_#{ name }", name
      end
      singleton_class.send :define_method, name, &func
    end
  end

  class MetaHell::Proxy < ::BasicObject
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
