require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Ivars_with_Procs_as_Methods

  describe "[mh] via procs methods" do
    context "can act as an enhancer that enhances a class via" do
      Sandbox_1 = Sandboxer.spawn
      it "enabling ivars that hold procs to act as methods of the object" do
        Sandbox_1.with self
        module Sandbox_1
          class Foo
            def initialize
              @bar = -> { :baz }
            end
            Subject_[ self, :bar ]
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
            Subject_[ self, :@_secret, :wahoo ]
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
              @_go = -> { :thats_right }
              @_hi = -> x { "HI:#{ x }" }
            end
            Subject_[ self ].as_public_method :_hi
            Subject_[ self ].as_private_getter :@_go, :yep
          end

          foo = Foo.new

          foo._hi 'X' #=> "HI:X"
          -> do
            foo.yep
          end.should raise_error( NoMethodError,
                       ::Regexp.new( "\\Aprivate\\ method\\ `yep'\\ called\\ for" ) )
          foo.send( :yep ).should eql :thats_right
        end
      end
    end
    context "Alternately you can use the struct-like producer to create an entire" do
      Sandbox_4 = Sandboxer.spawn
      it "class with this behavior like so" do
        Sandbox_4.with self
        module Sandbox_4
          Wahoo = Subject_[].new :fief do
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
