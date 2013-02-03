module Skylab::MetaHell
                                  # ( we find ourselves making a lot of
                                  # functionial proxies like this )
  module Proxy::Nice
    def self.new *a
      kls = Proxy::Functional.new(* a )
      kls.class_exec do
        define_method :class do kls end
      end
      kls
    end
  end
end
