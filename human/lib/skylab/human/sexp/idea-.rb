module Skylab::Human

  module Sexp

    class Idea_

      Attributes_actor_.call( self,
        syntactic_category: nil,
      )

      class << self

        alias_method :via_sexp_stream__, :via_argument_scanner

        alias_method :via_sexp__, :via_iambic

        # #itch [#fi-035] - it would be nice to get nothing from methodic..

        private :new
      end  # >>

      def initialize
        @__slots = Common_::Box.new
      end

      def process_argument_scanner_passively st  # #[#fi-022]
        super && normalize
      end

      def normalize
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
          :via, :polymorphic_upstream,
          :add,
          :object_argument,
          polymorphic_upstream )
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
          :via, :polymorphic_upstream,
          :add,
          :subject_argument,
          polymorphic_upstream )
      end

      def verb=

        _edit_self(
          :via, :polymorphic_upstream,
          :add,
          :verb,
          polymorphic_upstream )
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

        Here_::Idea_Argument_Adapter_for_Nounish_::Object
      end

      def __subject_argument__component_association

        yield :can, :add

        Here_::Idea_Argument_Adapter_for_Nounish_::Subject
      end

      def __verb__component_association

        yield :can, :add

        Here_::Idea_Argument_Adapter_for_Verbish___
      end

      def __add__component qk, & _

        o = qk.value_x
        @__slots.add o.slot_symbol, o
        o
      end

      def result_for_component_mutation_session_when_changed _, &__
        ACHIEVED_
      end
    end
  end
end
