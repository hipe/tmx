module Skylab::Zerk

  class Compound_Adapter___

    def initialize acs, rsx

      @ACS = acs
      @_line_yielder = rsx.line_yielder
      @_view_controller = rsx.view_controller
    end

    # -- expression

    def to_button_name_stream

      nf_a = []
      qkn_a = []
      st = ACS_::For_Interface::To_stream[ @ACS ]

      # (during #description, use the above somehow ..)

      begin
        qkn = st.gets
        qkn or break
        nf_a.push qkn.name
        qkn_a.push qkn
        redo
      end while nil

      @last_buttonesques_ = qkn_a

      Callback_::Stream.via_nonsparse_array nf_a
    end

    attr_reader :last_buttonesques_

    # -- user input

    def process_mutable_string_input s

      s.strip!  # here we strip not chomp because node names are more normal
      if s.length.zero?
        @_line_yielder << "(nothing entered.)"
      else
        ___process_nonblank_string s
      end
      NIL_
    end

    def ___process_nonblank_string s

      x = Interpret_buttonesque_[ s, self ]
      if x
        @_view_controller.push_stack_frame_for x
      end
      NIL_
    end

    # -- events

    def handler_for sym, *_
      if :interrupt == sym
        -> do
          @_view_controller.pop_me_off_of_the_stack self
          NIL_
        end
      end
    end

    def receive_uncategorized_emission i_a, & ev_p

      @_view_controller.receive_uncategorized_emission i_a, & ev_p
      UNRELIABLE_
    end

    # -- as structure

    attr_reader(
      :ACS,
    )

    # -- instrinsic shape reflection

    def is_branchesque_
      true
    end
  end
end
