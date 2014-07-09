module Skylab::MetaHell

  module FUN::Deprecated  # :+#deprecation:pending

    o = FUN.redefiner

    # deprecation for the below two explained [#039]

    o[:private_attr_reader] = -> * i_a do
      public ; attr_reader( * i_a ) ; private( * i_a ) ; private
    end

    o[:private_attr_accessor] = -> * i_a do
      public ; attr_accessor( * i_a ) ; private( * i_a ) ; private
    end

    o[:module_defines_method_in_some_manner] = -> mod, i do
      mod.method_defined? i or mod.private_method_defined? i
    end
  end
end
