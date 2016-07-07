require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - contextualization - express subject association", wip: true do

    TS_Joist_[ self ]
    use :memoizer_methods
    use :NLP_EN_contextualization
    use :NLP_EN_contextualization_ham

    context "(the normalest example)" do

      emit_by_ do |oes_p|

        selection_stack_as no_name_, assoc_( :item ), assoc_( :add )

        subject_association_as assoc_( :left_shark )

        oes_p.call :error, :expression do |y|
          y << "should have been at #{ highlight 'this' } superbowl"
          y << "sho nuff"
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

      emit_by_ do |oes_p|

        selection_stack_as no_name_, assoc_( :frob )

        subject_association_as assoc_( :left_shark )

        oes_p.call :info, :expression do |y|
          y << "(was convered to #{ highlight 'this' })"
          y << "yup"
        end
      end

      it "added newline at the very end" do
        first_line_[ -1 ].should eql NEWLINE_
      end

      it "for now, the `while` pattern is employed.." do
        first_line_.should match(
          %r(\A\(while frobing, left shark was convered to \*\* this \*\*\)) )
      end
    end

    def ham_ad_hoc_customizations_ o

      # (the below is a sketch for how we might style it in [ze] niCLI..)

      o.express_subject_association.integratedly

      o.express_trilean.classically_but.on_failed = -> kns do

        kns.initial_phrase_conjunction = nil
        kns.inflected_verb = "couldn't #{ kns.verb_lemma.value_x }"
        NIL_
      end

      same = -> asc do
        asc.name.as_human
      end

      o.to_say_selection_stack_item = -> asc do
        if asc.name
          same[ asc ]
        end
      end

      o.to_say_subject_association = same
      NIL_
    end
  end
end
