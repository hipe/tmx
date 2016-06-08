module Skylab::Autonomous_Component_System

  module Interpretation

    find_handler_method = nil
    Build_emission_handler_builder_ = -> asc, acs do  # 1x here

      # "component handler builder" (experimental): pass component listener
      # both the component value and association whenever it emits.
      # #open "go this away" this overcomplicated eventmodel that we don't use

      -> cmp do  # :[#006]:codepoint-1

        -> * i_a, & x_p do

          qkn = Common_::Qualified_Knownness[ cmp, asc ]

          st = Common_::Polymorphic_Stream.via_array i_a

          m = find_handler_method[ st, acs ]

          if m
            _maybe_none = st.flush_remaining_to_array

            acs.send m, qkn, * _maybe_none, & x_p
          else

            acs.receive_component_event qkn, i_a, & x_p
          end
        end
      end
    end

    find_handler_method = -> st, acs do

      # shift elements from the channel on to the method
      # name as long as there is a matching method

      base = :"receive_component__"
      begin

        try_m = :"#{ base }#{ st.current_token }__"

        if acs.respond_to? try_m
          m = try_m
          st.advance_one
          if st.unparsed_exists
            base = try_m
            redo
          end
        end
        break
      end while nil
      m
    end

    IDENTITY_ = -> x { x }
  end
end
