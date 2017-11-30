require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] operation - tenet 3 - edit existing" do

    TS_[ self ]
    use :memoizer_methods

    it "subject class loads" do
      _subject_class
    end

    it "set when valid" do

      bike = _subject_class.new 'shinola'
      expect( bike.make ).to eql 'shinola'
      ok = bike.edit_entity :set, :make, 'schwinn'
      expect( ok ).to eql true
      expect( bike.make ).to eql 'schwinn'

      expect( bike._num_times_change_event_occurred ).to eql 1
    end

    it "set when invalid" do

      i_a_a = [] ; msg_a = []

      bike = _subject_class.new 'zeepie'

      ok = bike.edit_entity :set, :make, 'SCHWINN' do | *i_a, & ev_p |
        i_a_a.push i_a ; msg_a.push ev_p[ [] ]
      end

      expect( ok ).to eql false

      expect( bike.make ).to eql 'zeepie'

      expect( i_a_a ).to eql [ [ :error, :expression ] ]
      expect( msg_a ).to eql [ [ "all caps? \"SCHWINN\"" ] ]

      expect( bike._num_times_change_event_occurred ).to be_nil
    end

    it "setting one valid and one invalid? ATOMIC!" do

      bike = _subject_class.new 'one', 2

      ok = bike.edit_entity :set, :year, 3, :set, :make, 'ohai'
      expect( ok ).to eql true
      expect( bike.make ).to eql 'ohai'
      expect( bike.year ).to eql 3

      expect( bike._num_times_change_event_occurred ).to eql 1

      ev_i_a = []
      ok = bike.edit_entity :set, :year, 4, :set, :make, 'DOOHAH' do | * a |
        ev_i_a.push a ; :_no_see_
      end
      expect( ok ).to eql false
      expect( bike.make ).to eql 'ohai'
      expect( bike.year ).to eql 3

      expect( ev_i_a ).to eql [[ :error, :expression ]]

      expect( bike._num_times_change_event_occurred ).to eql 1
    end

    shared_subject :_subject_class do

      class ACS_28_6_9_Bicycle

        def initialize make, year=nil
          @make = make
          @year = year
        end

        def edit_entity * x_a, & p

          _p_p = -> _ do
            p
          end

          ACS_[].edit x_a, self, & _p_p
        end

        attr_reader(
          :make,
          :year,
        )

        def __make__component_association

          yield :can, :set

          -> in_st, & p_p do

            s = in_st.gets_one
            if /\A[a-z]+\z/ =~ s
              Common_::KnownKnown[ s ]
            else

              if p_p
                p_p[ nil ].call :error, :expression do | y |
                  y << "all caps? #{ s.inspect }"
                end
              end
              false
            end
          end
        end

        def __year__component_association

          yield :can, :set

          -> in_st do
            x = in_st.gets_one
            x.respond_to?( :bit_length ) or self._SANITY
            Common_::KnownKnown[ x ]
          end
        end

        def __set__component qk, & _x_p
          instance_variable_set qk.name.as_ivar, qk.value
          true
        end

        attr_reader :_num_times_change_event_occurred

        def result_for_component_mutation_session_when_changed _, & __
          @_num_times_change_event_occurred ||= 0
          @_num_times_change_event_occurred += 1
          true
        end

        ACS_ = -> do
          Home_
        end

        self
      end
    end
  end
end
