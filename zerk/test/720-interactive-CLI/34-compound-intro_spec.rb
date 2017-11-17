require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] iCLI - compound intro" do

    TS_[ self ]
    use :memoizer_methods
    use :want_screens

    context "(this one reactive model)" do

      _SAME_BUTTON_LINE = '[h]ave-dinner'

      context "(have dinner without doing anything for it)" do

        given do
          input 'next-leve', 'have-din'
        end

        it "the first non-root compound frame screen looked good" do
          screens[ -2 ].serr_lines.last == _SAME_BUTTON_LINE or fail
        end

        it "first line is synopsis of the problem" do
          first_line.include?( "'have-dinner' is missing required parameter" ) or fail
        end

        it "second thru N lines are the chain.." do
          a = lines
          a[ 1 ].include?( "'have-dinner', must 'take-subway'" ) or fail
          a[ 2 ].include?( "to 'take-subway', must 'get-card'" ) or fail
          a[ 3 ].include?( "'get-card' is missing required parameter" ) or fail
        end

        it "these buttons" do
          _these_buttons
        end
      end

      # input 'money', '1', 'next-level', 'hav'
      # the above worked at writing ("insufficient funds")

      context "(with sufficient funds)" do

        given do
          input 'money', '5', 'next-level', 'hav'
        end

        it "output message (from the business proc) indicating success" do
          _ = first_line
          _ == "(dinner: you have $5 (still!). using '_subway_card_' you took subway here.)" or fail
        end

        it "these buttons" do
          _these_buttons
        end
      end

      define_method :_these_buttons do
        last_line == _SAME_BUTTON_LINE or fail
      end

      def subject_root_ACS_class
        My_fixture_top_ACS_class[ :Class_50_Dep_Graphs ]::Subnode_01_Dinner
      end
    end
  end
end
