module Skylab::MetaHell
  module Klass::Creator
    def self.extended mod
      mod.send(:include, ExtensorInstanceMethods)
    end
    PARSE_OPTS = ->(opts) do
      extends = nil
      opts.each do |k, v|
        case k
        when :extends ; extends = v
        else          ; fail("no: #{k.inspect}")
        end
      end
      extends
    end
    BUILD_CLASS_DEFINITION = ->(full_name, extends, klass_body) do
      ->(_example_group) do
        superclass = get_module(extends)
        parts = full_name.to_s.split('__')
        klass_name = parts.pop
        mod = build_module(parts)
        mod.const_set(klass_name, Class.new(*[superclass].compact).tap { |k|
          _my_name = mod == base_module ? full_name.to_s : "#{mod}::#{klass_name}"
          k.singleton_class.send(:define_method, :to_s) { _my_name }
          klass_body and k.class_eval(&klass_body)
        })
      end
    end
    def klass(full_name, opts={}, &klass_body)
      extends = PARSE_OPTS.call(opts)
      defn = BUILD_CLASS_DEFINITION.call(full_name, extends, klass_body)
      let(full_name, &defn)
    end
  end
end
module Skylab::MetaHell::KlassCreator
  module InstanceMethods
    include ::Skylab::MetaHell::Modul::Creator::InstanceMethods
    def klass!(full_name, opts={}, &klass_body)
      extends = PARSE_OPTS.call(opts)
      defn = BUILD_CLASS_DEFINITION.call(full_name, extends, klass_body)
      instance_eval(&defn)
    end
    def base_module
      @base_module ||= Module.new
    end
    def get_module mixed
      case mixed
      when NilClass, FalseClass, Module ; mixed
      else                              ; fail("no: #{mixed.inspect}")
      end
    end
  end
  module ExtensorInstanceMethods
    include ::Skylab::MetaHell::Modul::Creator::InstanceMethods
    def get_module mixed
      case mixed
      when NilClass, FalseClass, Module ; mixed
      else                              ; send(mixed)
      end
    end
  end
end

