require_relative 'test-support'

module Skylab::MetaHell::TestSupport::FUN::Fields_::Contoured_

  ::Skylab::MetaHell::TestSupport::FUN::Fields_[ Contoured__TestSupport = self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::FUN::Fields_::Contoured_" do
    context "use it" do
      Sandbox_1 = Sandboxer.spawn
      it "like so" do
        Sandbox_1.with self
        module Sandbox_1
          class Foo
            MetaHell::FUN::Fields_::Contoured_[ self,
              :absorber_method_name, :absorb,
              :proc, :foo,
              :memoized, :proc, :bar,
              :method, :bif,
              :memoized, :method, :baz ]
          end

          f = Foo.new ; f.absorb( :foo, -> { :yes } ) ; f.foo.should eql( :yes )
        end
      end
    end
  end
end
