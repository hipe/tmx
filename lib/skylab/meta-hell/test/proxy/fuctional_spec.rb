require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Proxy::Functional
  ::Skylab::MetaHell::TestSupport::Proxy[ Functional_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ MetaHell }::Proxy::Function" do

    def pee ; 'wee' end

    def dee ; @dee_meyers end

    it "produces a class, like a struct. but construct pxy with a hash" do
      kls = MetaHell::Proxy::Functional.new :foo, :bar

      pxy = kls.new foo: -> x { "#{ pee }-#{ x }-#{ dee }" },
                    bar: -> { @dee_meyers }
      @dee_meyers = 'who'
      pxy.foo( 'y' ).should eql( 'wee-y-who' )
      pxy.bar.should eql( 'who' )
    end

    it "but don't touch the sides" do
      kls = MetaHell::Proxy::Functional.new :zerpie, :derkie, :tata

      proc do
        kls.new murphy: :bed
      end.should raise_error( ::NameError, /no member 'murphy' in struct/ )

      proc do
        kls.new zerpie: :herpie
      end.should raise_error( ::ArgumentError,
                             /your proxy must define \(derkie, tata\)/ )
    end
  end
end
