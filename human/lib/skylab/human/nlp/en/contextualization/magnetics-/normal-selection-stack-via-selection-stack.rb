module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Normal_Selection_Stack_via_Selection_Stack < Magnet_

      def execute

        a = []

        ps = @ps_

        ea = ps.expression_agent
        ea ||= Non_expressive_expresion_agent_instance___[]

        st = __build_selection_stack_value_scanner

        default_p = ps.to_say_selection_stack_item
        default_p ||= Express_selection_stack_item___

        _first_p = ps.to_say_first_selection_stack_item

        first = -> do
          _x = st.gets_one
          a.push ea.calculate _x, & ( _first_p || default_p )
        end

        x = nil

        nonlast = -> do
          a.push ea.calculate x, & default_p
        end

        _NFL_p = ps.to_say_nonfirst_last_selection_stack_item

        nonfirst_last = -> do
          a.push ea.calculate x, & ( _NFL_p || default_p )
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

        ss = @ps_.selection_stack
        ss_a = ::Array.try_convert ss
        if ! ss_a
          ss_a = ss.to_array  # assume [#ba-002]#LL
        end

        # secondly, the selection stack can be sparse so stream over it this way:

        Common_::Polymorphic_Stream.via_array ss_a
      end

      # ==

      Express_selection_stack_item___ = -> x do
        nf = x.name  # :[#048]. allows root to have a name
        if nf
          nm nf
        end
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
