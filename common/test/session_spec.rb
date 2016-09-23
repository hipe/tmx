require_relative 'test-support'

module Skylab::Common::TestSupport

  describe "[co] session - ivars with procs as methods" do

    extend TS_
    use :memoizer_methods

    it "enhance a class via enabling ivars to hold procs that act as methods" do

      class Foo
        def initialize
          @bar = -> { :baz }
        end
        Home_::Session::Ivars_with_Procs_as_Methods[ self, :bar ]
      end

      Foo.new.bar.should eql :baz
    end

    it "you can indicate an ivar with a name other than the method name" do

      class Bar
        def initialize
          @_secret = -> { :ting }
        end
        Home_::Session::Ivars_with_Procs_as_Methods[ self, :@_secret, :wahoo ]
      end

      Bar.new.wahoo.should eql :ting
    end

    context "you can use the DSL to control visibility" do

      before :all do

        class X_s_Baz

          def initialize
            @_go = -> { :thats_right }
            @_hi = -> x { "HI:#{ x }" }
          end

          o = Home_::Session::Ivars_with_Procs_as_Methods

          o[ self ].as_public_method :_hi

          o[ self ].as_private_getter :@_go, :yep
        end
      end

      shared_subject :foo do
        X_s_Baz.new
      end

      it "calling this public method works" do
        foo._hi( 'X' ).should eql "HI:X"
      end

      it "calling this private method does not" do

        _rx = ::Regexp.new "\\Aprivate\\ method\\ `yep'\\ called\\ for"

        begin
          foo.yep
        rescue NoMethodError => e
        end

        e.message.should match _rx
      end

      it "but privately you can still call it" do
        foo.send( :yep ).should eql :thats_right
      end
    end

    it "you can use the struct-like producer to create the class automatically" do

      Wahoo = Home_::Session::Ivars_with_Procs_as_Methods.new :fief do
        def initialize
          @fief = -> { :zap }
        end
      end

      Wahoo.new.fief.should eql :zap
    end
  end
end
