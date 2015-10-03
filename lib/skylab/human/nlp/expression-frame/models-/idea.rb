module Skylab::Human

  class NLP::Expression_Frame

    class Models_::Idea

      Callback_::Actor.methodic self, :properties,

        :syntactic_category

      def initialize & edit_p

        @__slots = Callback_::Box.new
        instance_exec( & edit_p )
        h = remove_instance_variable( :@__slots ).h_
        h.each_pair do | sym, x |
          instance_variable_set :"@#{ sym }", x
        end
      end

      attr_reader :syntactic_category

      def object
        ( object_atom || object_list || object_count ) && true
      end

      def to_object_count_and_list_and_atom
        [ object_count, object_list, object_atom ]
      end

      attr_reader :object_atom, :object_count, :object_list

      private def object=

        _edit_self(
          :via, :polymorphic_upstream,
          :add,
          :object_argument,
          polymorphic_upstream )
      end

      def self.__object_argument__component_model
        EF_::Models_::Argument_Adapter::Nounish::Object
      end

      def subject
        ( subject_atom || subject_list || subject_count ) && true
      end

      def to_subject_count_and_list_and_atom
        [ subject_count, subject_list, subject_atom ]
      end

      attr_reader :subject_atom, :subject_count, :subject_list

      private def subject=

        _edit_self(
          :via, :polymorphic_upstream,
          :add,
          :subject_argument,
          polymorphic_upstream )
      end

      def self.__subject_argument__component_model
        EF_::Models_::Argument_Adapter::Nounish::Subject
      end

      private def verb=

        _edit_self(
          :via, :polymorphic_upstream,
          :add,
          :verb,
          polymorphic_upstream )
      end

      def self.__verb__component_model
        EF_::Models_::Argument_Adapter::Verbish
      end

      attr_reader :verb_argument

      attr_reader :negative

    private def negative=

        @negative = true
        KEEP_PARSING_
      end

      attr_reader :later_is_expected

    private def later_is_expected=

        @later_is_expected = true
        KEEP_PARSING_
      end

      attr_reader :more_is_expected

    private def more_is_expected=
        @more_is_expected = true
        KEEP_PARSING_
      end

      # ~

      def _edit_self * x_a, & x_p

        Home_.lib_.brazen::Autonomous_Component_System::
            Mutation_Session.edit x_a, self, & x_p
      end

      def mutable_body_for_mutation_session
        self
      end

      def __add__object_for_mutation_session o

        @__slots.add o.slot_symbol, o
        ACHIEVED_
      end

      def receive_changed_during_mutation_session
        ACHIEVED_
      end
    end
  end
end
