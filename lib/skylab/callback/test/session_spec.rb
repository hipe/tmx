require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Ivars_with_Procs_as_Methods

  describe "[mh] Ivars_with_Procs_as_Methods" do

    it "enhance a class via enabling ivars to hold procs that act as methods" do
      class Foo
        def initialize
          @bar = -> { :baz }
        end
        Subject_[ self, :bar ]
      end

      Foo.new.bar.should eql :baz
    end
    it "you can indicate an ivar with a name other than the method name" do
      class Bar
        def initialize
          @_secret = -> { :ting }
        end
        Subject_[ self, :@_secret, :wahoo ]
      end

      Bar.new.wahoo.should eql :ting
    end
    it "you can use the DSL to control visibility" do
      class Baz
        def initialize
          @_go = -> { :thats_right }
          @_hi = -> x { "HI:#{ x }" }
        end

        Subject_[ self ].as_public_method :_hi

        Subject_[ self ].as_private_getter :@_go, :yep

      end

      foo = Baz.new

      foo._hi( 'X' ).should eql "HI:X"
      -> do
        foo.yep
      end.should raise_error( NoMethodError,
                   ::Regexp.new( "\\Aprivate\\ method\\ `yep'\\ called\\ for" ) )
      foo.send( :yep ).should eql :thats_right
    end
    it "you can use the struct-like producer to create the class automatically" do
      Wahoo = Subject_[].new :fief do
        def initialize
          @fief = -> { :zap }
        end
      end

      Wahoo.new.fief.should eql :zap
    end
  end
end
