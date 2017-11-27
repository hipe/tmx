require_relative 'test-support'

module Skylab::Common::TestSupport

  describe "[co] session - ivars with procs as methods" do

    TS_[ self ]
    use :memoizer_methods

    it "enhance a class via enabling ivars to hold procs that act as methods" do

      class X_s_Foo
        def initialize
          @bar = -> { :baz }
        end
        Home_::Session::Ivars_with_Procs_as_Methods[ self, :bar ]
      end

      expect( X_s_Foo.new.bar ).to eql :baz
    end

    it "you can indicate an ivar with a name other than the method name" do

      class X_s_Bar
        def initialize
          @_secret = -> { :ting }
        end
        Home_::Session::Ivars_with_Procs_as_Methods[ self, :@_secret, :wahoo ]
      end

      expect( X_s_Bar.new.wahoo ).to eql :ting
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
        expect( foo._hi( 'X' ) ).to eql "HI:X"
      end

      it "calling this private method does not" do

        _rx = ::Regexp.new "\\Aprivate\\ method\\ `yep'\\ called\\ for"

        begin
          foo.yep
        rescue NoMethodError => e
        end

        expect( e.message ).to match _rx
      end

      it "but privately you can still call it" do
        expect( foo.send( :yep ) ).to eql :thats_right
      end
    end

    it "you can use the struct-like producer to create the class automatically" do

      X_s_Wahoo = Home_::Session::Ivars_with_Procs_as_Methods.new :fief do
        def initialize
          @fief = -> { :zap }
        end
      end

      expect( X_s_Wahoo.new.fief ).to eql :zap
    end
  end
end
