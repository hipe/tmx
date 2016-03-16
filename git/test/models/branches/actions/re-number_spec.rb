require_relative '../../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] models - branches - re-number" do

    extend TS_
    use :expect_event

    it "\"to\" and \"from\" must be in the collection" do

      _against [ 1, 3, 5 ], [ 2, 4, 999 ]

      _em = expect_not_OK_event :strange_items

      black_and_white( _em.cached_event_value ).should eql(
        "2 and 4 must be in the collection" )

      expect_failed
    end

    it "expand - results are in descending order" do

      _against [ 5,10,15,16,20,22,23 ], [ 15, 16, 4 ]

      _gets.should eql %w( 23 27 )
      _gets.should eql %w( 22 26 )
      _gets.should eql %w( 20 24 )
      _gets.should eql %w( 16 20 )
      _done
    end

    it "contract" do

      _against [ 1,2,3,9,10,12 ], [ 3, 9, -5 ]

      _gets.should eql %w( 9 4 )
      _gets.should eql %w( 10 05 )
      _gets.should eql %w( 12 07 )
      _done
    end

    it "contract too crowded" do

      _against [ 1, 3, 5, 7, 9, 11 ], [ 3, 9, -4 ]

      _em = expect_not_OK_event :too_much_squeeze

      black_and_white( _em.cached_event_value ).should eql(
       "between 3 and 9 there are 4 items.\n#{
        }desired contraction of -4 would bring distance down to 2, #{
         }but distance cannot go below 3 for 4 items." )

      expect_failed
    end

    def _against d_a, trip

      call_API( :branches, :re_number,
        :branch_name_stream,
        _d_a_to_st( d_a ),

        :from, trip.fetch( 0 ),
        :to, trip.fetch( 1 ),
        :plus_or_minus, trip.fetch( 2 ),
      )

      if @result
        @_st = remove_instance_variable :@result
      end
      NIL_
    end

    def _d_a_to_st d_a

      Callback_::Stream.via_nonsparse_array d_a do | d |
        d.to_s
      end
    end

    def _gets
      rn = @_st.gets
      if rn
        [ rn.from_name, rn.to_name ]
      end
    end

    def _done
      x = @_st.gets
      if x
        fail "done? #{ x.class }"
      end
    end
  end
end
