class Skylab::Issue::Models::Issues

  # this is only for debugging! probably this will go away after some time
  module Friendly
    def self.extended klass
      klass.extend Friendly::ClassMethods
      klass.friendly_class_init
      klass.send(:include, Friendly::InstanceMethods)
    end
  end
  module Friendly::InstanceMethods
    def me
      "#{self.class.friendly_name}#{@id ||= self.class.next_id}"
    end
  end
  module Friendly::ClassMethods
    def friendly_class_init
      id = 0
      singleton_class.send(:define_method, :next_id) { id += 1 }
      singleton_class.send(:undef_method, :friendly_class_init)
    end
    def friendly_name
      @friendly_name ||= name.match(/[^:]+$/)[0].gsub(/([a-z])([A-Z])/){ "#{$1}-#{$2}" }.downcase
    end
    attr_writer :friendly_name
  end
end

