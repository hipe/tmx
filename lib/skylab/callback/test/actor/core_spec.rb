require_relative 'test-support'

module Skylab::Callback::TestSupport::Actor

  describe "[cb] actor" do

    before :all do

      class Make_sandwich

        Subject_[].call self, :properties,
          :top_slice,
          :inside,
          :bottom_slice

        def initialize
          @bottom_slice = @top_slice = nil
          super
        end

        def execute
          @_number_of_times ||= 0
          @_number_of_times += 1
          [ @top_slice, @inside, @bottom_slice ]
        end

        attr_reader :_number_of_times
      end

      Make_pastrami_sandwich = Make_sandwich.curry_with :inside, :Pastrami

    end

    context "`curry_with`" do

      it "the curried actor executes when given iambic arguments" do

        Make_pastrami_sandwich.with( :top_slice, :A, :bottom_slice, :B ).
          should eql [ :A, :Pastrami, :B ]

        Make_pastrami_sandwich._number_of_times.should be_nil

      end

      it "and this weird thing with positional args" do

        Make_pastrami_sandwich[ :A_, :B_ ].should eql [ :A_, :Pastrami, :B_ ]

        Make_pastrami_sandwich._number_of_times.should be_nil
      end
    end

    context "`backwards_curry`" do

      it "minimal" do

        curried = Make_sandwich.backwards_curry[ :wheat ]

        curried.call( :sourdough, :tofu ).should eql [ :sourdough, :tofu, :wheat ]

        curried._number_of_times.should be_nil

      end
    end
  end
end
