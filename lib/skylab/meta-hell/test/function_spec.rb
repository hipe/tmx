require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Function

  ::Skylab::MetaHell::TestSupport[ Function_TestSupport = self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::Function" do
    context "context 1" do
      Sandbox_1 = Sandboxer.spawn
      it "usage:" do
        Sandbox_1.with self
        module Sandbox_1
          class Foo
            def initialize
              @bar = -> { :baz }
            end
            MetaHell::Function self, :bar
          end

          Foo.new.bar.should eql( :baz )
        end
      end
    end
    context "context 2" do
      Sandbox_2 = Sandboxer.spawn
      it "or use different ivars:" do
        Sandbox_2.with self
        module Sandbox_2
          class Foo
            def initialize
              @_secret = -> { :ting }
            end
            MetaHell::Function self, :@_secret, :wahoo
          end

          Foo.new.wahoo.should eql( :ting )
        end
      end
    end
    context "context 3" do
      Sandbox_3 = Sandboxer.spawn
      it "or use the DSL to control visibility:" do
        Sandbox_3.with self
        module Sandbox_3
          class Foo
            def initialize
              @_go = -> { :yep }
              @_hi = -> x { "HI:#{ x }" }
            end
            MetaHell::Function.enhance( self ).as_private_getter :@_go, :yep
            MetaHell::Function.enhance( self ).as_public_method :_hi
          end

          f = Foo.new

          f._hi 'X' #=> "HI:X"
          -> do
            f.yep
          end.should raise_error( NoMethodError,
                       ::Regexp.new( "\\Aprivate\\ method\\ `yep'\\ called\\ for" ) )
        end
      end
    end
    context "context 4" do
      Sandbox_4 = Sandboxer.spawn
      it "or if you like structs you can have it this way:" do
        Sandbox_4.with self
        module Sandbox_4
          Wahoo = MetaHell::Function::Class.new :fief
          class Wahoo
            def initialize
              @fief = -> { :zap }
            end
          end
          Wahoo.new.fief.should eql( :zap )
        end
      end
    end
  end
end
