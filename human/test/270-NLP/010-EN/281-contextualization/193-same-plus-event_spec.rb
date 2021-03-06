require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - contextualization - same but plus event" do

    # (would also be #C15n-test-family-4)

    TS_[ self ]
    use :memoizer_methods
    use :NLP_EN_contextualization
    use :NLP_EN_contextualization_DSL

    context "(voila)" do

      given do |p|

        selection_stack no_name_, assoc_( :item ), assoc_( :add )

        subject_association assoc_ :left_shark

        wat = -> s_a, _ev do
          s_a.join Home_::SPACE_
        end

        p.call :error, :itemzie_not_foundie do

          Home_.lib_.fields::Events::Extra.with(
            :unrecognized_token, 'bezo',
            :did_you_mean_tokens, [ 'wezo', 'dezo' ],
            :noun_lemma, 'kershploink',
            :suffixed_prepositional_phrase_context_proc, wat,
          )
        end

        begin_by do |o|
          testcase_family_4_customization_ o
          NIL
        end
      end

      it "the re-emitted channel is the same" do
        expect( channel_ ).to eql [ :error, :itemzie_not_foundie ] or fail
      end

      it "the last line is the same" do
        expect( second_line_ ).to eql "did you mean \"wezo\" or \"dezo\"?\n" or fail
      end

      it "you still get the (an) event emitted omg!!" do
        event_.noun_lemma == "kershploink" || fail
      end

      it "the first item has been contextualized (sensically by chance)" do
        expect( first_line_ ).to eql "left shark failed to add item because unrecognized kershploink \"bezo\"\n" or fail
      end
    end
  end
end
