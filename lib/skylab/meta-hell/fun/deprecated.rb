module Skylab::MetaHell

  module FUN::Deprecated

    o = FUN_.o

    # deprecation for the below two explained [#039]

    o[:private_attr_reader] = -> * i_a do
      public ; attr_reader( * i_a ) ; private( * i_a ) ; private
    end

    o[:private_attr_accessor] = -> * i_a do
      public ; attr_accessor( * i_a ) ; private( * i_a ) ; private
    end
  end
end
