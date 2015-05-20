module Skylab::Human

  class NLP::Expression_Frame

    class Models_::Idea

      Callback_::Actor.methodic self

      def initialize & edit_p

        @__slots = Callback_::Box.new
        instance_exec( & edit_p )
        h = remove_instance_variable( :@__slots ).h_
        h.each_pair do | sym, x |
          instance_variable_set :"@#{ sym }", x
        end
      end

      attr_reader :object_atom, :object_list

      private def object=

        _edit_self(
          :via, :polymorphic_upstream,
          :add,
          :object_argument,
          polymorphic_upstream )
      end

      def self.__object_argument__association_for_mutation_session
        EF_::Models_::Argument_Adapter::Nounish::Object
      end

      attr_reader :subject_atom, :subject_list

      private def subject=

        _edit_self(
          :via, :polymorphic_upstream,
          :add,
          :subject_argument,
          polymorphic_upstream )
      end

      def self.__subject_argument__association_for_mutation_session
        EF_::Models_::Argument_Adapter::Nounish::Subject
      end

      private def verb=

        _edit_self(
          :via, :polymorphic_upstream,
          :add,
          :verb,
          polymorphic_upstream )
      end

      def self.__verb__association_for_mutation_session
        EF_::Models_::Argument_Adapter::Verbish
      end

      attr_reader :verb_argument

      attr_reader :is_negative

    private def negative=

        @is_negative = true
        KEEP_PARSING_
      end

      attr_reader :implies_the_future

    private def imply_the_future=

        @implies_the_future = true
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

        @__slots.add o.slot_symbol, o
        ACHIEVED_
      end

      def receive_changed_during_mutation_session
        ACHIEVED_
      end
    end
  end
end
