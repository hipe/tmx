require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] operation - 1, 2, 4, 5 and 6" do

    TS_[ self ]
    use :memoizer_methods

    it "subject class loads" do
      _subject_class
    end

    it "typically, `new` is made private (tenet 1)" do

      begin
        _subject_class.new
      rescue ::NoMethodError => e
      end
      e.message.should match %r(^private method `new' called for )
    end

    it "tenet 2 (`edit_entity` creates); tenet 4 (..) and tenet 5 (`[]`)" do

      guy = _subject_class.edit_entity :set, :mi_nombre, "DAVE"
      guy.mi_nombre.should eql "DAVE"
    end

    it "sub-components can be `set` via their `[etc]` method (tenet 6)" do

      guy = _subject_class.edit_entity :set, :age, 26
      guy.age.as_digit.should eql 26
    end

    it "sub-components can be `set` multiple at once" do

      guy = _subject_class.edit_entity(
        :set, :mi_nombre, "DAVID",
        :set, :age, 27,
      )
      guy.mi_nombre.should eql 'DAVID'
      guy.age.as_digit.should eql 27
    end

    it "if you give an invalid sub component argument, events & false" do

      i_a_a = []
      msg_a = []

      guy = _subject_class.edit_entity(
        :set, :mi_nombre, "david"
      ) do | * i_a, & ev_p |
        i_a_a.push i_a
        msg_a.push ev_p[ [] ]
      end

      i_a_a.should eql [ [ :error, :expression ] ]
      msg_a.should eql [ [ "name must be in all caps" ] ]

      guy.should eql false
    end

    memoize :_subject_class do

      class ACS_28_6_3_One

        class << self

          def edit_entity * x_a, & p
            ACS_[].create x_a, new do | _ |
              p
            end
          end

          private :new
        end

        def __mi_nombre__component_association

          yield :can, :set

          -> st, & p_p do

            s = st.head_as_is
            if /\A[A-Z ]+\z/ =~ s
              st.advance_one
              Common_::KnownKnown[ s ]
            else

              _p = p_p[ nil ]

              _p.call :error, :expression do | y |
                y << "name must be in all caps"
              end

              false
            end
          end
        end

        def __age__component_association

          yield :can, :set

          ACS_28_6_3_Age
        end

        attr_reader :age, :mi_nombre

        def __set__component qk, & _x_p

          instance_variable_set qk.name.as_ivar, qk.value
          true
        end

        ACS_ = -> do
          Home_
        end
      end

      class ACS_28_6_3_Age

        def self.interpret_component st, & p
          d = st.gets_one
          if 0 > d
            self._COVER_ME
          else
            new d
          end
        end

        def initialize d
          @as_digit = d
        end

        attr_reader :as_digit
      end

      ACS_28_6_3_One
    end
  end
end
