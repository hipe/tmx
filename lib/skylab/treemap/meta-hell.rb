module Skylab::Treemap
  module MetaHell
    def redefine_method! name, prok
      if respond_to?(name)
        singleton_class.send(:alias_method, "orig_#{name}", name)
      end
      singleton_class.send(:define_method, name, &prok)
    end
  end
  class MetaHell::Proxy < Struct.new(:upstream)
    def method_missing m, *a, &b
      upstream.send(m, *a, &b)
    end
    def upstream! upstream
      self.upstream = upstream
      self
    end
    singleton_class.send(:alias_method, :actual_new, :new)
    def self.new hash
      Class.new(MetaHell::Proxy).class_eval do
        class << self
          alias_method :proxy_new, :new
          alias_method :new, :actual_new
        end
        hash.each do |k, wrap_proc|
          define_method(k) do |*a|
            wrap_proc.call(upstream.send(k, *a))
          end
        end
        self
      end
    end
  end
end

