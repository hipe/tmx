module Skylab::Zerk

  class NonInteractiveCLI

    class When_Help_ < Callback_::Actor::Dyadic

      # this help facility is engaged IFF the main interpreter has matched
      # (somehow) a token at the head of the argument stream that matches
      # a request for help.
      #
      #   • the argument stream is advanced past this matched token but
      #
      #   • you have the matchdata.

      def initialize md, cli
        @CLI = cli
        @matchdata = md
      end

      # once this help facility is engaged, there is no going back to the
      # main interpreter. from this point, some kind of help will be effected
      # no matter what.

      def execute

        _modality_frame = @CLI.release_selection_stack__
        @_upstream = @CLI.release_argument_stream__

        s = remove_instance_variable( :@matchdata )[ :eql ]
        if s
          __change_upstream_to_this_token s
        end

        @_frame = build_frame_for_modality_frame_ _modality_frame

        begin
        end while ___step
        NIL_
      end

      def __change_upstream_to_this_token s

        self._COVER_ME_this_is_all_a_code_sketch

        st = @_upstream
        if st.unparsed_exists
          __warn_about_ignored
        end

        @_upstream = Callback_::Polymorphic_Stream.via s ; nil
      end

      # as such there are now zero or more tokens remaining in the argument
      # stream for which it is the subject node's responsibility to behave
      # against. generally we interpret this like the main interpreter, where
      # we start with some frame as a given, and each next token is parsed by
      # whatever the current frame is, and in so doing a new frame is pushed
      # to the stack and so on until either uninterpretability is reached or
      # there are no more tokens to parse. whatever ends up being the top
      # frame is responsible for either expressing this uninterpretability
      # or displaying a help screen as appropriate.

      def ___step
        # all you can do is stop or keep going

        if @_upstream.no_unparsed_exists
          @_frame.effect_help_screen_
          NIL_
        else
          @_frame.step_
        end
      end

      # -- services

      def common_effect_help_screen_ ada, o

        o.invocation_expression = ada
        o.invocation_reflection = ada
        # o.command_string = .. hm..
        d = o.produce_result
        d.zero?  # sanity - assert shape
        @CLI.init_exitstatus_ d
        NIL_
      end

      def parse_one_modality_frame_ set_sym, modality_frame

        _oes_p = -> * i_a, & ev_p do
          @CLI.handle_ACS_emission_ i_a, & ev_p  # (hi.) unreliable
        end

        fr = modality_frame.lookup_and_attach_frame__(
          @_upstream.current_token,
          set_sym, & _oes_p )

        if fr
          @_upstream.advance_one
        end
        fr
      end

      def push_via_modality_frame_ vf
        _frame = build_frame_for_modality_frame_ vf
        @_frame = _frame
        KEEP_PARSING_
      end

      def build_frame_for_modality_frame_ vf
        _cls = Here_.const_get H___.fetch( vf._3_normal_shape_category_ ), false
        _cls.new vf, self
      end

      H___ = {
        compound: :Help_Frame_for_Compound___,
      }

      def init_exitstatus_for_ sym
        @CLI.init_exitstatus_for_ sym
      end

      def CLI_
        @CLI
      end

      def upstream_
        @_upstream
      end
    end
  end
end
