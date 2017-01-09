module Skylab::Permute

  module CLI

    Magnetics_::Tokenizer = Lazy_.call do

      _LONG_RX___ = /\A
        --
        (?<switch> [a-zA-Z0-9]+ (?:-[a-zA-Z0-9]+)* )
        (?: = (?<arg> .+ ) )?
      \z/x

      _SHORT_RX___ = /\A
        -
        (?<switch> [a-zA-Z0-9] )
        (?<arg> [^=]+ )?
      \z/x

      pair = -> v_x=nil, n_x=nil do
        Common_::Pair.via_value_and_name v_x, n_x
      end

      o = Home_.lib_.basic::StateMachine::begin_definition

      o.add_state :beginning,
        :can_transition_to, [ :long_switch ]

      o.add_state :after_a_pair,
        :can_transition_to, [ :short_switch, :long_switch, :ending ]

      o.add_state :long_switch,
        :entered_by_regex, _LONG_RX___,
        :on_entry, -> ob, md do
          sw, arg = md.captures

          ob << pair[ sw, :long_switch ]

          if arg
            ob << pair[ arg, :value ]
            :after_a_pair
          else
            :value
          end
        end

      o.add_state :short_switch,
        :entered_by_regex, _SHORT_RX___,
        :on_entry, -> ob, md do
          sw, arg = md.captures

          ob << pair[ sw, :short_switch ]

          if arg
            ob << pair[ arg, :value ]
            :after_a_pair
          else
            :value
          end
        end

      o.add_state :value,
        :entered_by, -> st do
          if st.unparsed_exists
            st
          end
        end,
        :on_entry, -> ob, st do

          ob << pair[ st.gets_one, :value ]

          :after_a_pair
        end

      o.add_state :ending,
        :entered_by, -> _st do

          # any state that indicated this as a possible next
          # state may enter without barrier from this state

          :_trueish_
        end,

        :on_entry, -> ob, st do
          NIL_  # you must declare that you have no next state
        end

      o.flush_to_grammar
    end
  end
end
