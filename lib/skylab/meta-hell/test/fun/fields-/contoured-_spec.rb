require_relative 'test-support'

module Skylab::MetaHell::TestSupport::FUN::Fields_::Contoured_

  ::Skylab::MetaHell::TestSupport::FUN::Fields_[ self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::FUN::Fields_::Contoured_" do
    context "use it" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          class Foo
            MetaHell::FUN::Fields_::Contoured_[ self,
              :absorb_method, :absorb,
              :proc, :foo,
              :memoized, :proc, :bar,
              :method, :bif,
              :memoized, :method, :baz ]
              public :absorb
          end
        end
      end
      it "like so" do
        Sandbox_1.with self
        module Sandbox_1
          f = Foo.new ; f.absorb( :foo, -> { :yes } ) ; f.foo.should eql( :yes )
        end
      end
      it "and so" do
        Sandbox_1.with self
        module Sandbox_1
          @ohai = :hi
          f = Foo.new ; f.absorb(  :foo, -> { 'x' },
                                   :bar, -> { "y:#{ @ohai }" },
                                   :bif, -> { "_#{ foo }_" },
                                   :baz, -> { "<#{ foo }>" } )
          f.foo.should eql( 'x' )
          f.bar.should eql( 'y:hi' )
          f.bif.should eql( '_x_' )
          ( f.baz.object_id == f.baz.object_id ).should eql( true )
        end
      end
    end
    context "[ `required` ] `field`s -" do
      Sandbox_2 = Sandboxer.spawn
      before :all do
        Sandbox_2.with self
        module Sandbox_2
          class Foo
            MetaHell::FUN::Fields_::Contoured_[ self,
              :required, :field, :foo, :field, :bar ]
          end
        end
      end
      it "failing to pass a required field triggers an argument error" do
        Sandbox_2.with self
        module Sandbox_2
          -> do
            Foo.new
          end.should raise_error( ArgumentError,
                       ::Regexp.new( "\\Amissing\\ required\\ argument\\ \\-\\ foo\\z" ) )
        end
      end
      it "passing nil is considered the same as not passing an argument" do
        Sandbox_2.with self
        module Sandbox_2
          -> do
            Foo.new( :foo, nil )
          end.should raise_error( ArgumentError,
                       ::Regexp.new( "\\Amissing\\ required\\ argument\\ \\-\\ foo\\z" ) )
        end
      end
      it "passing false is not the same as passing nil, passing false is valid." do
        Sandbox_2.with self
        module Sandbox_2
          Foo.new( :foo, false ).foo.should eql( false )
        end
      end
      it "you can of course pass nil as the value for a non-required field" do
        Sandbox_2.with self
        module Sandbox_2
          Foo.new( :foo, :x, :bar, nil ).bar.should eql( nil )
        end
      end
    end
  end
end
