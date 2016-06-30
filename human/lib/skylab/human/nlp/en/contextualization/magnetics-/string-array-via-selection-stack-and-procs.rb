module Skylab::Human

  class NLP::EN::Contextualization

    class Transition_ < Common_::Actor::Monadic

      def initialize kns
        @knowns_ = kns
      end

      def say_subject_association_
        _p = @knowns_.to_say_subject_association
        _p ||= Express_subject_association___
        say_subject_association_by_( & _p )
      end

      Express_subject_association___ = -> asc do
        nm asc.name
      end

      def say_subject_association_by_ & p
        @knowns_.expression_agent.calculate @knowns_.subject_association, & p
      end

      # --

      def selection_stack_as_moniker_array__

        o = begin_selection_stack_sayer_

        _p = @knowns_.to_say_selection_stack_item
        _p ||= Express_selection_stack_item___
        o.say_other_by = _p

        o.build_array
      end

      Express_selection_stack_item___ = -> x do
        nf = x.name  # :[#048]. allows root to have a name
        if nf
          nm nf
        end
      end

      def begin_selection_stack_sayer_
        Selection_Stack_Sayer___.new self, @knowns_
      end

      def __selection_stack_as_knkn_stream

        # to be safe, we'll allow nils to be in the s.s. so:

        item_a = __selection_stack_as_array

        Common_::Stream.via_times item_a.length do |d|

          Common_::Known_Known[ item_a.fetch d ]
        end
      end

      def __selection_stack_as_array

        ss = @knowns_.selection_stack
        ss_a = ::Array.try_convert ss
        if ss_a
          ss_a
        else
          ss.to_array  # assuming [#ba-002]#LL
        end
      end

      # --

      def derive_trilean_from_channel_if_necessary_
        if ! @knowns_.trilean
          send DERIVE_TRILEAN___.fetch @knowns_.channel.fetch 0
        end
        NIL_
      end

      DERIVE_TRILEAN___ = {
        info: :__set_trilean_when_info,
        error: :___set_trilean_when_error,
      }

      def ___set_trilean_when_error
        @knowns_.trilean = false ; nil
      end

      def __set_trilean_when_info
        @knowns_.trilean = nil ; nil
      end

      # --

      class Selection_Stack_Sayer___

        def initialize trns, kns

          @knowns_ = kns
          @_transition = trns

          @say_first_by = nil
          @say_nonfirst_last_by = nil
        end

        attr_writer(
          :say_first_by,
          :say_other_by,  # required
          :say_nonfirst_last_by,
        )

        def build_array

          a = []

          e = @knowns_.expression_agent || Not_expresion_agent_[]

          st = @_transition.__selection_stack_as_knkn_stream
          kn = st.gets
          if kn

            a.push e.calculate kn.value_x, & ( @say_first_by || @say_other_by )

            kn = st.gets
            if kn
              begin
                nxt = st.gets
                if nxt
                  a.push e.calculate kn.value_x, & @say_other_by
                  kn = nxt
                  redo
                end
                _p = @say_nonfirst_last_by || @say_other_by
                a.push e.calculate kn.value_x, & _p
                break
              end while nil
            end
          end
          a
        end
      end

      Not_expresion_agent_ = Lazy_.call do

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
    end
  end
end
