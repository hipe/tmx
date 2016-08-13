require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - contextualization - express subject association" do

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
          _customize o
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
          _customize o
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

    def _customize o

      # (the below is a sketch for how we might style it in [ze] niCLI..)
      #
      # (order matters while #open [#043] because it's building a magnetic
      # function stack, so highest level (last to run) first)

      _but = o.express_trilean.classically.but

      _but.on_failed = -> sp, pos do  # surface parts

        sp.prefixed_cojoinder = nil
        sp.verb_subject = nil
        sp.inflected_verb = "couldn't #{ pos.verb_lemma }"
        sp.verb_object = pos.verb_object
        sp.suffixed_cojoinder = "because"
        NIL_
      end

      o.express_subject_association.integratedly

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
