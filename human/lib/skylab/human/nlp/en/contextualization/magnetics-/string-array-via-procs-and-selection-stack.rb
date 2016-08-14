module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::String_Array_via_Selection_Stack_and_Procs

      class << self

        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize
        @to_say_first = nil
        @to_say_nonfirst_last = nil
      end

      attr_writer(
        :expression_agent,
        :selection_stack,
        :to_say_first,
        :to_say_other,  # required
        :to_say_nonfirst_last,
      )

      def execute

        a = []
        e = @expression_agent || Non_expressive_expresion_agent_instance___[]

        st = __build_selection_stack_value_scanner

        first = -> do
          _x = st.gets_one
          a.push e.calculate _x, & ( @to_say_first || @to_say_other )
        end

        x = nil

        nonlast = -> do
          a.push e.calculate x, & @to_say_other
        end

        nonfirst_last = -> do
          _p = @to_say_nonfirst_last || @to_say_other
          a.push e.calculate x, & _p
        end

        if st.unparsed_exists
          first[]
          if st.unparsed_exists
            begin
              x = st.gets_one
              st.no_unparsed_exists && break
              nonlast[]
              redo
            end while nil
            nonfirst_last[]
          end
        end

        a
      end

      def __build_selection_stack_value_scanner

        # first of all, the ss might be a linked list (move this whenever)

        ss = @selection_stack
        ss_a = ::Array.try_convert ss
        if ! ss_a
          ss_a = ss.to_array  # assume [#ba-002]#LL
        end

        # secondly, the selection stack can be sparse so stream over it this way:

        Common_::Polymorphic_Stream.via_array ss_a
      end

      # ==

      Non_expressive_expresion_agent_instance___ = Lazy_.call do

        # if the client didn't pass an expression agent, the case may be
        # that of callbacks A) she expects that they are *not* called in
        # the context of *any* expression agent and B) all things being
        # equal she may expect that her callbacks are called in their
        # original context..

        class Not_Expression_Agent____

          def calculate x, & p
            p[ x ]  # call it with its original context..
          end

          self
        end.new
      end

      # ==
    end
  end
end
# #history: was "transition"
