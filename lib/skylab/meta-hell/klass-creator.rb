module Skylab::MetaHell
  module KlassCreator
    def klass(full_name, opts={}, &block)
      opts = opts.dup
      extends = opts.delete(:extends)
      opts.any? and fail('no')
      let(full_name) do
        superclass = extends ? send(extends) : nil
        parts = full_name.to_s.split('__')
        klass_name = parts.pop
        mod = parts.reduce(base_module) do |mod, part|
          unless mod.const_defined?(part)
            mod.const_set(part, Module.new.tap { |m|
              _my_name = mod == base_module ? part.to_s : "#{mod}::#{part}"
              m.singleton_class.send(:define_method, :to_s) { _my_name }
            })
          end
          mod.const_get(part)
        end
        mod.const_set(klass_name, Class.new(*[superclass].compact).tap { |k|
          _my_name = mod == base_module ? full_name.to_s : "#{mod}::#{klass_name}"
          k.singleton_class.send(:define_method, :to_s) { _my_name }
          block and k.class_eval(&block)
        })
      end
    end
  end
end

