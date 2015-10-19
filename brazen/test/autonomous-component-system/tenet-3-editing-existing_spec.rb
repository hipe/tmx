require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] ACS tenet 3 - edit existing" do

    extend TS_

    use :danger_memo

    it "subject class loads" do
      _subject_class
    end

    it "set when valid" do

      bike = _subject_class.new 'shinola'
      bike.make.should eql 'shinola'
      ok = bike.edit_entity :set, :make, 'schwinn'
      ok.should eql true
      bike.make.should eql 'schwinn'

      bike._num_times_change_event_occurred.should eql 1
    end

    it "set when invalid" do

      i_a_a = [] ; msg_a = []

      bike = _subject_class.new 'zeepie'
      ok = bike.edit_entity :set, :make, 'SCHWINN' do | *i_a, & ev_p |
        i_a_a.push i_a ; msg_a.push ev_p[ [] ]
      end
      ok.should eql false
      bike.make.should eql 'zeepie'

      i_a_a.should eql [ [ :error, :expression ] ]
      msg_a.should eql [ [ "all caps? \"SCHWINN\"" ] ]

      bike._num_times_change_event_occurred.should be_nil
    end

    it "setting one valid and one invalid? ATOMIC!" do

      bike = _subject_class.new 'one', 2

      ok = bike.edit_entity :set, :year, 3, :set, :make, 'ohai'
      ok.should eql true
      bike.make.should eql 'ohai'
      bike.year.should eql 3

      bike._num_times_change_event_occurred.should eql 1

      ok = bike.edit_entity :set, :year, 4, :set, :make, 'DOOHAH'
      ok.should eql false
      bike.make.should eql 'ohai'
      bike.year.should eql 3

      bike._num_times_change_event_occurred.should eql 1
    end

    dangerous_memoize_ :_subject_class do

      class ACS_3_Bicycle

        def initialize make, year=nil
          @make = make
          @year = year
        end

        def edit_entity * x_a, & x_p
          ACS_[].edit x_a, self, & x_p
        end

        attr_reader(
          :make,
          :year,
        )

        def __make__component_association

          yield :can, :set

          -> in_st, & oes_p do
            s = in_st.gets_one
            if /\A[a-z]+\z/ =~ s
              ACS_[]::Value_Wrapper[ s ]
            else

              if oes_p
                oes_p.call :error, :expression do |y|
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
            ACS_[]::Value_Wrapper[ x ]
          end
        end

        def __set__component x, ca, & oes_p
          instance_variable_set ca.name.as_ivar, x
          true
        end

        attr_reader :_num_times_change_event_occurred

        def result_for_component_mutation_session_when_changed _, & __
          @_num_times_change_event_occurred ||= 0
          @_num_times_change_event_occurred += 1
          true
        end

        ACS_ = -> do
          Home_::Autonomous_Component_System
        end

        self
      end
    end
  end
end
