require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - contextualization - nestedly", wip: true do

    TS_Joist_[ self ]
    use :memoizer_methods
    use :NLP_EN_contextualization

    it "(look like sole in-situ use case)" do  # :[#043]"C"

      o = Home_::NLP::EN::Contextualization.new

      o.expression_agent = common_expag_

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

      o.express_selection_stack.nestedly

      _a = o.express_into []

      _a.should eql(
       [ "'moe' must be ** dootily ** hah in 'eenie' in 'meenie' in 'miney'\n",
         "yup\n" ] )
    end

    it "(stowaway) when pipeline can't be built" do

      o = subject_class_.new do | * x_a, & ev_p |
        ev_p[ :_xx_ ]
      end

      o.express_selection_stack.classically
      o.express_trilean.classically

      begin
        o.to_emission_handler
      rescue ::KeyError => e
      end

      e.message.should match %r(\Afrom the starting state 'emission_handler)
    end
  end
end
