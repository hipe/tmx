module Skylab::Treemap
  module MetaHell
    def redefine_method! name, prok
      if respond_to?(name)
        singleton_class.send(:alias_method, "orig_#{name}", name)
      end
      singleton_class.send(:define_method, name, &prok)
    end
  end
end

