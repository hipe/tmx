require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - contextualization - nestedly" do

    TS_Joist_[ self ]
    use :memoizer_methods
    use :NLP_EN_contextualization

    it "(look like sole in-situ use case)" do  # :[#043]"C"

      o = subject_class_.begin

      o.express_selection_stack.nestedly

      _expag = common_expag_

      o.expression_agent = _expag

      o.emission_proc = -> y do
        y << "must be #{ highlight 'dootily' } hah"
        y << "yup"
      end

      o.to_say_subject_association = -> sym do
        code sym
      end

      o.to_say_selection_stack_item = -> x do
        "in #{ code x }"
      end

      o.selection_stack = %i( eenie meenie miney )

      o.subject_association = :moe

      _a = o.express_into []

      _a.should eql(
       [ "'moe' must be ** dootily ** hah in 'eenie' in 'meenie' in 'miney'\n",
         "yup\n" ] )
    end
  end
end
