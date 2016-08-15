require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - contextualization - express subject association" do

    # (this would be #C15n-test-family-4)

    TS_Joist_[ self ]
    use :memoizer_methods
    use :NLP_EN_contextualization
    use :NLP_EN_contextualization_DSL

    context "(the normalest example)" do

      given do |oes_p|

        selection_stack no_name_, assoc_( :item ), assoc_( :add )

        subject_association assoc_ :left_shark

        oes_p.call :error, :expression do |y|
          y << "should have been at #{ highlight 'this' } superbowl"
          y << "sho nuff"
        end

        begin_by do |o|
          testcase_family_4_customization_ o
          NIL
        end
      end

      it "the re-emitted channel is the same" do
        channel_.should eql [ :error, :expression ]
      end

      it "the second line has a newline added" do
        second_line_.should eql "sho nuff\n"
      end

      it "the first line gets inflected with \"couldn't frob knob because..\"" do
        first_line_.should match %r(\Acouldn't add item because)
      end

      it "the association is placed as the subject of the predicate" do
        first_line_.should match %r(\bleft shark should have been\b)
      end
    end

    context "(parens, info, one level shallower)" do

      given do |oes_p|

        selection_stack no_name_, assoc_( :frob )

        subject_association assoc_ :left_shark

        oes_p.call :info, :expression do |y|
          y << "(was converted to #{ highlight 'this' })"
          y << "yup"
        end

        begin_by do |o|
          testcase_family_4_customization_ o
        end
      end

      it "added newline at the very end" do
        first_line_[ -1 ].should eql NEWLINE_
      end

      it "for now, the `while` pattern is employed.." do
        first_line_.should match(
          %r(\A\(while frobing, left shark was converted to \*\* this \*\*\)) )
      end
    end
  end
end
