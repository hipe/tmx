module Skylab::Human

  module ExpressionPipeline_

    class Idea_

      ATTRIBUTES = Attributes_.call(
        syntactic_category: nil,
      )

      class << self

        def interpret_ scn
          ATTRIBUTES.init_via_argument_scanner_plus new, scn
        end

        private :new
      end  # >>

      def initialize
        @__slots = Common_::Box.new
      end

      def as_attributes_actor_normalize
        h = remove_instance_variable( :@__slots ).h_
        h.each_pair do | sym, x |
          instance_variable_set :"@#{ sym }", x
        end
        KEEP_PARSING_
      end

      attr_reader :syntactic_category

      def object
        ( object_atom || object_list || object_count ) && true
      end

      def to_object_count_and_list_and_atom
        [ object_count, object_list, object_atom ]
      end

      attr_reader :object_atom, :object_count, :object_list

      def object=

        _edit_self(
          :via, :argument_scanner,
          :add,
          :object_argument,
          @_argument_scanner_ )
      end

      def subject
        ( subject_atom || subject_list || subject_count ) && true
      end

      def to_subject_count_and_list_and_atom
        [ subject_count, subject_list, subject_atom ]
      end

      attr_reader :subject_atom, :subject_count, :subject_list

      def subject=

        _edit_self(
          :via, :argument_scanner,
          :add,
          :subject_argument,
          @_argument_scanner_ )
      end

      def verb=

        _edit_self(
          :via, :argument_scanner,
          :add,
          :verb,
          @_argument_scanner_ )
      end

      attr_reader :verb_argument

      attr_reader :negative

      def negative=

        @negative = true
        KEEP_PARSING_
      end

      attr_reader :later_is_expected

      def later_is_expected=

        @later_is_expected = true
        KEEP_PARSING_
      end

      attr_reader :more_is_expected

      def more_is_expected=
        @more_is_expected = true
        KEEP_PARSING_
      end

      private(
        :negative=,
        :object=,
        :subject=,
        :verb=,
        :later_is_expected=,
        :more_is_expected=,
      )

      # ~

      def _edit_self * x_a, & x_p

        Home_.lib_.ACS.edit x_a, self, & x_p  # ACS_
      end

      def __object_argument__component_association

        yield :can, :add

        ExpressionPipeline_::IdeaArgumentAdapter_via_Nounish_::Object
      end

      def __subject_argument__component_association

        yield :can, :add

        ExpressionPipeline_::IdeaArgumentAdapter_via_Nounish_::Subject
      end

      def __verb__component_association

        yield :can, :add

        ExpressionPipeline_::IdeaArgumentAdapter_via_Verbish___
      end

      def __add__component qk, & _

        o = qk.value
        @__slots.add o.slot_symbol, o
        o
      end

      def result_for_component_mutation_session_when_changed _, &__
        ACHIEVED_
      end
    end
  end
end
