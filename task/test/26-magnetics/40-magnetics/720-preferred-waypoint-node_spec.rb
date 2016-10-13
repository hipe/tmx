require_relative '../../test-support'

module Skylab::Task::TestSupport

  describe "[ta] magnetics - magnetics - pathfinding node preferences" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics
    use :magnetics_solve_for_X

    context "(context)" do

      it "without preference, choses longest thing" do

        given_array_ _same_thing
        target_ :first_line_map  # (when we targeted `contextualized_expression`, new problems)
        expect_stack_(
          :First_Line_Map_via_Lemmas_and_Lemmato_Trilean_Idiom,
          :Lemmas_via_Normal_Selection_Stack,
          :Normal_Selection_Stack_via_Selection_Stack,
          :Lemmato_Trilean_Idiom_via_Trilean,
          :Trilean_via_Channel,
        )
      end

      it "with preference, choses preferred thing" do

        given_array_ _same_thing
        target_ :first_line_map
        customize_by_ do |o|
          o.preferred_waypoint_node = :event
        end
        expect_stack_(
          :First_Line_Map_via_Evento_Trilean_Idiom,
          :Evento_Trilean_Idiom_via_Event_and_Trilean,
          :Trilean_via_Channel,
        )
      end

      dangerous_memoize :_same_thing do
        [
          :channel,
          :emission_shape,
          :event,
          :selection_stack,
          :subject_association,
        ].freeze
      end

      dangerous_memoize :collection_ do
        collection_via_path_ fixture_path_ 'magnetics-example-collection-720.list.txt'
      end
    end
  end
end
