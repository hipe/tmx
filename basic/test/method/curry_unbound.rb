require_relative 'test-support'

module Skylab::Basic::TestSupport::Method::CU

  ::Skylab::Basic::TestSupport::Method[ self ]

  include Constants

  extend TestSupport_::Quickie

  Home_ = Home_

  describe "[ba] method curry unbound - good for ONE curry" do

    before :all do

      class Wazzerly

        def sandwich bread, inside, toothpick
          "(#{ bread }(#{ inside })#{ toothpick })"
        end

        define_method :reuben, Parent_Subject_[].unbound.
          new( instance_method( :sandwich ) ).curry[ :rye ]


        def not_curriable foo, bar=nil
        end
      end

      WAZZERLY = Wazzerly.new
    end

    it "arity is less than 1 - X" do
      -> do
        class Wazzerly
          Parent_Subject_[].unbound instance_method :not_curiable
        end
      end.should raise_error ::ArgumentError, /\bfor now, arity must be #{
        }greater than or equal to 1 \(had -2\)/
    end

    it "when you call it with too few args - X" do
      -> do
        WAZZERLY.reuben :one
      end.should raise_error ::ArgumentError, /\bwrong number of arguments #{
        }\(2 for 3\)/
    end

    it "when you call it with not enough args - X" do
      -> do
        WAZZERLY.reuben :one, :two, :three
      end.should raise_error ::ArgumentError, /\bwrong number.+#{
        }\(4 for 3\)/
    end

    it "just right - o" do
      _s = WAZZERLY.reuben :saukerkraut, :toothpick
      _s.should eql '(rye(saukerkraut)toothpick)'
    end

    Parent_Subject_ = -> do
      Home_::Method.curry
    end
  end
end
