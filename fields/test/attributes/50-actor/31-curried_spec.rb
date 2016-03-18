require_relative '../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes_actor  # #[#017]
  module Attributes::Actor

    TS_.describe "[fi] attributes - actor - curried" do

      TS_[ self ]
      use :memoizer_methods
      Here_[ self ]

      context "(context 1)" do

        shared_subject :_class do

          class X_Curried_A

            Subject_proc_[].call( self,
              :top_slice,
              :inside,
              :bottom_slice,
            )

            def initialize
              # @top_slice = nil
              # @bottom_slice = nil
            end

            def execute
              @_number_of_times ||= 0
              @_number_of_times += 1
              [ @top_slice, @inside, @bottom_slice ]
            end

            attr_reader :_number_of_times

            self
          end
        end

        shared_subject :_curried_actor do

          o =  _class.curry_with :inside, :Pastrami
          # X_Curried_B_Make_pastrami_sandwich = o  # it's not a class
          o
        end

        it "the curried actor executes when given iambic arguments" do

          ca = _curried_actor

          _ = ca.with :top_slice, :A, :bottom_slice, :B

          _.should eql [ :A, :Pastrami, :B ]

          ca._number_of_times.nil? or fail
        end

        it "and this weird thing with positional args" do

          ca = _curried_actor

          _ = ca[ :A_, :B_ ]

          _.should eql [ :A_, :Pastrami, :B_ ]

          ca._number_of_times.nil? or fail
        end

        it "`backwards_curry`" do

          ca = _class.backwards_curry[ :wheat ]

          _ = ca.call :sourdough, :tofu

          _.should eql [ :sourdough, :tofu, :wheat ]

          ca._number_of_times.nil? or fail
        end
      end
    end
  end
end
