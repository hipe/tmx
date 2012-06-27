module Skylab::MetaHell
  module KlassCreator
    def self.extended mod
      mod.send(:include, ::Skylab::MetaHell::ModulCreator::InstanceMethods)
    end
    def klass(full_name, opts={}, &block)
      opts = opts.dup
      extends = opts.delete(:extends)
      opts.any? and fail('no')
      let(full_name) do
        superclass = extends ? send(extends) : nil
        parts = full_name.to_s.split('__')
        klass_name = parts.pop
        mod = build_module(parts)
        mod.const_set(klass_name, Class.new(*[superclass].compact).tap { |k|
          _my_name = mod == base_module ? full_name.to_s : "#{mod}::#{klass_name}"
          k.singleton_class.send(:define_method, :to_s) { _my_name }
          block and k.class_eval(&block)
        })
      end
    end
  end
end

