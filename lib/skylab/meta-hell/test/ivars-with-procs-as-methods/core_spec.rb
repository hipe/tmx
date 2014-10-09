require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Function

  ::Skylab::MetaHell::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  MetaHell_ = MetaHell_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  describe "[mh] Function" do
    context "`MetaHell_::Function` can act as an enhancer that enhances a class via" do
      Sandbox_1 = Sandboxer.spawn
      it "enabling ivars that hold procs to act as methods of the object" do
        Sandbox_1.with self
        module Sandbox_1
          class Foo
            def initialize
              @bar = -> { :baz }
            end
            MetaHell_::Function self, :bar
          end

          Foo.new.bar.should eql( :baz )
        end
      end
    end
    context "You can use ivars with arbitrary names" do
      Sandbox_2 = Sandboxer.spawn
      it "like so" do
        Sandbox_2.with self
        module Sandbox_2
          class Foo
            def initialize
              @_secret = -> { :ting }
            end
            MetaHell_::Function self, :@_secret, :wahoo
          end

          Foo.new.wahoo.should eql( :ting )
        end
      end
    end
    context "You can use the DSL to control visibility" do
      Sandbox_3 = Sandboxer.spawn
      it "like so" do
        Sandbox_3.with self
        module Sandbox_3
          class Foo
            def initialize
              @_go = -> { :yep }
              @_hi = -> x { "HI:#{ x }" }
            end
            MetaHell_::Function.enhance( self ).as_private_getter :@_go, :yep
            MetaHell_::Function.enhance( self ).as_public_method :_hi
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
    context "Alternately you can use the struct-like producer to create an entire" do
      Sandbox_4 = Sandboxer.spawn
      it "class with this behavior like so" do
        Sandbox_4.with self
        module Sandbox_4
          Wahoo = MetaHell_::Function::Class.new :fief
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
