module Skylab::Human

  class NLP::Expression_Frame

    class Models_::Idea

      Callback_::Actor.methodic self

      def initialize & edit_p
        instance_exec( & edit_p )
      end

      # ~ object & subject

      attr_reader(
        :has__object__,
        :has__object_atom__,
        :has__object_list__,
        :object_atom,
        :object_list,

        :has__subject__,
        :has__subject_atom__,
        :has__subject_list__,
        :subject_atom,
        :subject_list )

    private

      def object=

        _edit_self(
          :via, :polymorphic_upstream,
          :add,
          :object_argument,
          polymorphic_upstream )
      end

      def self.__object_argument__association_for_mutation_session
        EF_::Models_::Argument::Object_Argument
      end

      def subject=

        _edit_self(
          :via, :polymorphic_upstream,
          :add,
          :subject_argument,
          polymorphic_upstream )
      end

      def self.__subject_argument__association_for_mutation_session
        EF_::Models_::Argument::Subject_Argument
      end

    public

      # ~ verb & modification (in subjective descending popularity order)

      def is_negative
        has__negative__
      end

      attr_reader :has__negative__

      def has_implication_of_future
        has__implication_of_future__
      end

    private def negative=

        @has__negative__ = true
        KEEP_PARSING_
      end

      # ~

      attr_reader :has__implication_of_future__

    private def imply_the_future=

        @has__implication_of_future__ = true
        KEEP_PARSING_
      end

      # ~

      def _edit_self * x_a, & x_p

        Hu_.lib_.brazen::Mutation_Session.edit x_a, self, & x_p
      end

      def mutable_body_for_mutation_session
        self
      end

      def __add__object_for_mutation_session o

        instance_variable_set(
          :"@has__#{ o.term_category_symbol_ }__",
          true )

        sym = :"#{ o.term_category_symbol_ }_#{ o.shape_category_symbol_ }"

        instance_variable_set( :"@has__#{ sym }__", true )

        instance_variable_set :"@#{ sym }", o

        ACHIEVED_
      end

      def receive_changed_during_mutation_session
        ACHIEVED_
      end
    end
  end
end
