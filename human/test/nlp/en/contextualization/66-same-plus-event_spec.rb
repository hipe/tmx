require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - contextualization - same but with event" do

    # (would also be #C15n-test-family-4)

    TS_Joist_[ self ]
    use :memoizer_methods
    use :NLP_EN_contextualization
    use :NLP_EN_contextualization_DSL

    context "(voila)" do

      given do |oes_p|

        selection_stack no_name_, assoc_( :item ), assoc_( :add )

        subject_association assoc_ :left_shark

        wat = -> s_a, _ev do
          s_a.join Home_::SPACE_
        end

        oes_p.call :error, :extra_properties do

          Home_.lib_.fields::Events::Extra.new_with(
            :name_x_a, [ 'bezo' ],
            :did_you_mean_i_a, [ 'wezo', 'dezo' ],
            :lemma, 'kershploink',
            :suffixed_prepositional_phrase_context_proc, wat,
          )
        end

        begin_by do |o|
          testcase_family_4_customization_ o
          NIL
        end
      end

      it "the re-emitted channel is the same" do
        channel_ == [ :error, :extra_properties ] || fail
      end

      it "the last line is the same" do
        second_line_ == "did you mean \"wezo\" or \"dezo\"?\n" || fail
      end

      it "you still get the (an) event emitted omg!!" do
        event_.lemma == 'kershploink' || fail
      end

      it "but the first line has been (nonsensically) mutated omg!!" do
        first_line_ == "couldn't add item because left shark unrecognized kershploink \"bezo\"\n" || fail
      end
    end
  end
end
