require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - contextualization - against subject association without channel" do

    # :#C15n-test-family-3

    TS_[ self ]
    use :memoizer_methods
    use :NLP_EN_contextualization
    use :NLP_EN_contextualization_DSL

    context "(look like sole in-situ use case)" do

      given do |_|

        selection_stack( * %i( eenie meenie miney ) )

        subject_association :moe

        begin_by do |o|

          __common o

          # (here no channel, just emission proc)

          o.emission_proc = -> y do
            y << "must be #{ highlight 'dootily' } hah"
            y << "yup"
          end
        end

        lines_only
      end

      it "first line" do
        first_line_ == "'moe' must be ** dootily ** hah in 'eenie' in 'meenie' in 'miney'\n" || fail
      end

      it "2nd line" do
        second_line_ == "yup\n" || fail
      end
    end

    def __common o

      o.to_say_subject_association = -> sym do
        code sym
      end

      o.to_say_selection_stack_item = -> x do
        "in #{ code x }"
      end
    end
  end
end
