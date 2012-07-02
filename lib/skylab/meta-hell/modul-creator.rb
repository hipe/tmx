module Skylab::MetaHell
  module ModulCreator
    def self.extended mod
      mod.send(:include, ModulCreator::InstanceMethods)
    end
    def modul full_name, &block
      let(full_name) do
        modul(full_name, &block)
      end
    end
  end
  module ModulCreator::InstanceMethods
    def build_module parts
      base_module or fail("please set base_module")
      parts.reduce(base_module) do |mod, part|
        unless mod.const_defined?(part)
          mod.const_set(part, Module.new.tap { |m|
            _my_name = mod == base_module ? part.to_s : "#{mod}::#{part}"
            m.singleton_class.send(:define_method, :to_s) { _my_name }
          })
        end
        mod.const_get(part)
      end
    end
    def modul full_name, &body
      mod = build_module(full_name.to_s.split('__'))
      mod.module_eval(&body)
      mod
    end
  end
end
