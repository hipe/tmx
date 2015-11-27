require 'skylab/bnf2treetop'
require 'skylab/test_support'

module Skylab::BNF2Treetop::TestSupport

  def self.[] tcc
    tcc.send :define_singleton_method, :use, Use___
  end

  _TS = self

  cache = {}
  Use___ = -> sym do

    _ = cache.fetch sym do
      x = TestSupport_.fancy_lookup sym, _TS
      cache[ sym ] = x
      x
    end

    _[ self ]
  end

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.enable_kernel_describe

  Callback_ = ::Skylab::Callback

  Callback_::Autoloader[ self, ::File.dirname( __FILE__ ) ]

  Home_ = ::Skylab::BNF2Treetop
  NEWLINE_ = Home_::NEWLINE_
  SPACE_ = Home_::SPACE_
  UNDERSCORE_ = Home_::UNDERSCORE_
end
